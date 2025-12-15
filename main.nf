include {FASTQC} from './modules/fastqc'
include {TRIM} from './modules/trimmomatic'
include {BOWTIE2_BUILD} from './modules/bowtie2_build'
include {BOWTIE2_ALIGN} from './modules/bowtie2_align'
include {SAMTOOLS_FLAGSTAT} from './modules/samtools_flagstat'
include {SAMTOOLS_SORT} from './modules/samtools_sort'
include {SAMTOOLS_VIEW} from './modules/samtools_view'
include {SAMTOOLS_IDX} from './modules/samtools_idx'
include {MULTIQC} from './modules/multiqc'
include {BAMCOVERAGE} from './modules/deeptools_bamcoverage'
include {CALLPEAKS} from './modules/macs3_callpeaks'
include {BEDTOOLS_INTERSECT} from './modules/bedtools_intersect'
include {BEDTOOLS_REMOVE} from './modules/bedtools_remove'
include {ANNOTATE_CDC1} from './modules/homer_annotatepeaks_cdc1'
include {ANNOTATE_CDC2} from './modules/homer_annotatepeaks_cdc2'
include {FIND_MOTIFS_GENOME_CDC1} from './modules/homer_findmotifsgenome_cdc1'
include {FIND_MOTIFS_GENOME_CDC2} from './modules/homer_findmotifsgenome_cdc2'
include {BEDTOOLS_MERGE} from './modules/bedtools_merge'
include {COMPUTEMATRIX_CDC1} from './modules/deeptools_computematrix_cdc1'
include {COMPUTEMATRIX_CDC2} from './modules/deeptools_computematrix_cdc2'
include {PLOTHEATMAP_CDC1} from './modules/deeptools_plotheatmap_cdc1'
include {PLOTHEATMAP_CDC2} from './modules/deeptools_plotheatmap_cdc2'
include {GTF_TO_TSS} from './modules/gtf_to_tss'
include {TSS_ENRICHMENT} from './modules/tss_enrichment'

workflow {
    // construct initial channel
    Channel.fromPath(params.samplesheet)
    | splitCsv( header: true )
    | map{ row -> tuple(row.name, file(row.path)) }
    | set { read_ch }

    //read_ch.view()

    // initial quality control
    TRIM(read_ch, params.adapter_fa)
    FASTQC(TRIM.out.trimmed)

    // build genome and align with bowtie2
    BOWTIE2_BUILD(params.genome)
    BOWTIE2_ALIGN(TRIM.out.trimmed, BOWTIE2_BUILD.out.index, BOWTIE2_BUILD.out.name)

    // sort alignments
    SAMTOOLS_SORT(BOWTIE2_ALIGN.out)

    // remove alignments with mtDNA
    SAMTOOLS_VIEW(SAMTOOLS_SORT.out)

    // index alignments
    SAMTOOLS_IDX(SAMTOOLS_VIEW.out)

    // calculate alignment stats
    SAMTOOLS_FLAGSTAT(BOWTIE2_ALIGN.out.bam)

    // make channel collecting all qc outputs needed for MULTIQC
    multiqc_ch = FASTQC.out.zip
        .mix(TRIM.out.log, SAMTOOLS_FLAGSTAT.out.txt)
        .map { tuple -> tuple[1] }
        .collect()
        .map { files -> files.flatten() }

    // call MULTIQC
    MULTIQC(multiqc_ch)

    // generate bigwig files
    BAMCOVERAGE(SAMTOOLS_IDX.out)

    // peak calling
    CALLPEAKS(SAMTOOLS_IDX.out)

    // pair samples by name for intersect
    peaks_for_frip = CALLPEAKS.out.peaks
    bams_for_frip = SAMTOOLS_IDX.out

    // join by sample name
    frip_input = bams_for_frip.join(peaks_for_frip)
        .map { sample, bam, bai, peaks -> 
            tuple(sample, bam, bai, sample, peaks) 
        }

    // produce single set of reproducible peaks
    BEDTOOLS_INTERSECT(frip_input)

    // filter ENCODE blacklist peaks
    BEDTOOLS_REMOVE(CALLPEAKS.out.peaks, params.blacklist)

    // create channels for Diffbind significant peaks
    diffbind_cdc1 = Channel.fromPath("results/diffbind/cdc1_significant_peaks.bed")
        .map { bed -> tuple("cdc1_diffbind", bed) }
    
    diffbind_cdc2 = Channel.fromPath("results/diffbind/cdc2_significant_peaks.bed")
        .map { bed -> tuple("cdc2_diffbind", bed) }

    // annotate peaks to their nearest genomic feature
    ANNOTATE_CDC1(diffbind_cdc1, params.genome, params.gtf)
    ANNOTATE_CDC2(diffbind_cdc2, params.genome, params.gtf)

    // motif enrichment analysis on reproducible filtered peaks
    FIND_MOTIFS_GENOME_CDC1(diffbind_cdc1, params.genome)
    FIND_MOTIFS_GENOME_CDC2(diffbind_cdc2, params.genome)

    // combine all filtered peaks into one consensus peak set
    all_filtered_peaks = BEDTOOLS_REMOVE.out.filtered
        .map { sample, bed -> bed }
        .collect()

    BEDTOOLS_MERGE(all_filtered_peaks)

    // split bigWigs into cDC1 and cDC2 channels
    cdc1_bigwigs = BAMCOVERAGE.out
        .filter { sample, bw -> sample.toString().contains('_rep1') }
        .map { sample, bw -> bw }
        .collect()

    cdc2_bigwigs = BAMCOVERAGE.out
        .filter { sample, bw -> sample.toString().contains('_rep2') }
        .map { sample, bw -> bw }
        .collect()

    // create matrices for each cell type
    COMPUTEMATRIX_CDC1(cdc1_bigwigs, BEDTOOLS_MERGE.out.merged, params.window)
    COMPUTEMATRIX_CDC2(cdc2_bigwigs, BEDTOOLS_MERGE.out.merged, params.window)

    // generate heatmaps for each cell type
    PLOTHEATMAP_CDC1(COMPUTEMATRIX_CDC1.out.matrix)
    PLOTHEATMAP_CDC2(COMPUTEMATRIX_CDC2.out.matrix)

    // convert GTF to TSS BED file
    GTF_TO_TSS(params.gtf)
    
    // calculate TSS enrichment using bigwigs
    TSS_ENRICHMENT(BAMCOVERAGE.out, GTF_TO_TSS.out.tss_bed)
}