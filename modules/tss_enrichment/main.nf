#!/usr/bin/env nextflow

process TSS_ENRICHMENT {
    label 'process_medium'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir "${params.outdir}/tss_enrichment", mode: 'copy'

    input:
    tuple val(sample), path(bw)
    path(tss_bed)

    output:
    tuple val(sample), path("${sample}_tss_enrichment.txt"), emit: scores
    tuple val(sample), path("${sample}_tss_profile.png"), emit: plot
    tuple val(sample), path("${sample}_matrix.gz"), emit: matrix

    script:
    """
    # calculate coverage around TSS (-2kb to +2kb)
    computeMatrix reference-point \
        --referencePoint center \
        -b 2000 -a 2000 \
        -R ${tss_bed} \
        -S ${bw} \
        --binSize 10 \
        -o ${sample}_matrix.gz \
        --outFileNameMatrix ${sample}_matrix.tab

    # create profile plot
    plotProfile \
        -m ${sample}_matrix.gz \
        -out ${sample}_tss_profile.png \
        --perGroup \
        --plotTitle "${sample} TSS Enrichment" \
        --yAxisLabel "Read Density" \
        --plotHeight 7 \
        --plotWidth 10

    # calculate TSS enrichment score
    python3 << 'EOF'
import numpy as np
import warnings
warnings.filterwarnings('ignore')

try:
    matrix = np.loadtxt("${sample}_matrix.tab", skiprows=3)
    
    if matrix.size == 0:
        print("WARNING: Empty matrix!")
        enrichment = 0.0
    elif np.all(matrix == 0):
        print("WARNING: All values in matrix are zero!")
        enrichment = 0.0
    else:
        n_regions, n_bins = matrix.shape
        print(f"Matrix shape: {n_regions} regions x {n_bins} bins")
        
        bin_size = 10
        center_bin = n_bins // 2
        
        # TSS region: +/- 50bp = +/- 5 bins around center
        tss_bins = 5
        tss_start = center_bin - tss_bins
        tss_end = center_bin + tss_bins
        
        # flank region: exclude +/- 100bp (+/- 10 bins) around center
        flank_bins = 10
        flank_left_end = center_bin - flank_bins
        flank_right_start = center_bin + flank_bins
        
        # calculate signals
        tss_signal = np.nanmean(matrix[:, tss_start:tss_end])
        flank_left = matrix[:, :flank_left_end]
        flank_right = matrix[:, flank_right_start:]
        flank_signal = np.nanmean(np.concatenate([flank_left, flank_right], axis=1))
        
        print(f"Center bin: {center_bin}")
        print(f"TSS bins: {tss_start} to {tss_end}")
        print(f"TSS signal: {tss_signal:.4f}")
        print(f"Flank signal: {flank_signal:.4f}")
        
        # calculate enrichment
        if flank_signal > 0 and not np.isnan(flank_signal) and not np.isnan(tss_signal):
            enrichment = tss_signal / flank_signal
        else:
            print("WARNING: Cannot calculate enrichment (zero or NaN values)")
            enrichment = 0.0
        
        # handle invalid values
        if np.isnan(enrichment) or np.isinf(enrichment):
            print("WARNING: Enrichment is NaN or Inf, setting to 0")
            enrichment = 0.0
        else:
            print(f"TSS Enrichment Score for ${sample}: {enrichment:.2f}")

except Exception as e:
    print(f"ERROR: {e}")
    import traceback
    traceback.print_exc()
    enrichment = 0.0

# write result
with open("${sample}_tss_enrichment.txt", "w") as f:
    f.write("sample\\ttss_enrichment_score\\n")
    f.write(f"${sample}\\t{enrichment:.2f}\\n")
EOF
    """

    stub:
    """
    echo "sample\ttss_enrichment_score" > ${sample}_tss_enrichment.txt
    echo "${sample}\t5.0" >> ${sample}_tss_enrichment.txt
    touch ${sample}_tss_profile.png
    """
}