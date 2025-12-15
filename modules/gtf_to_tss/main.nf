#!/usr/bin/env nextflow

process GTF_TO_TSS {
    label 'process_single'
    publishDir "${params.outdir}/refs", mode: 'copy'

    input:
    path(gtf)

    output:
    path("tss.bed"), emit: tss_bed

    script:
    """
    # extract TSS from GTF file
    awk 'BEGIN {OFS="\\t"} 
    \$3 == "gene" {
        match(\$0, /gene_name "([^"]+)"/, arr)
        gene_name = arr[1]
        
        if (\$7 == "+") {
            tss = \$4
        } else {
            tss = \$5
        }
        
        print \$1, tss-1, tss, gene_name, 0, \$7
    }' ${gtf} > tss_raw.bed
    
    # convert RefSeq to UCSC chromosome names
    python3 << 'PYEOF'
chrom_map = {
    'NC_000067.7': 'chr1',
    'NC_000068.8': 'chr2', 
    'NC_000069.7': 'chr3',
    'NC_000070.7': 'chr4',
    'NC_000071.7': 'chr5',
    'NC_000072.7': 'chr6',
    'NC_000073.7': 'chr7',
    'NC_000074.7': 'chr8',
    'NC_000075.7': 'chr9',
    'NC_000076.7': 'chr10',
    'NC_000077.7': 'chr11',
    'NC_000078.7': 'chr12',
    'NC_000079.7': 'chr13',
    'NC_000080.7': 'chr14',
    'NC_000081.7': 'chr15',
    'NC_000082.7': 'chr16',
    'NC_000083.7': 'chr17',
    'NC_000084.7': 'chr18',
    'NC_000085.7': 'chr19',
    'NC_000086.8': 'chrX',
    'NC_000087.8': 'chrY',
    'NC_005089.1': 'chrM'
}

with open('tss_raw.bed', 'r') as infile, open('tss.bed', 'w') as outfile:
    for line in infile:
        fields = line.strip().split('\\t')
        if len(fields) >= 6:
            old_chr = fields[0]
            if old_chr in chrom_map:
                fields[0] = chrom_map[old_chr]
                outfile.write('\\t'.join(fields) + '\\n')
PYEOF

    # sort the output
    sort -k1,1 -k2,2n tss.bed > tss_sorted.bed
    mv tss_sorted.bed tss.bed
    
    echo "Created TSS BED file with \$(wc -l < tss.bed) entries"
    """

    stub:
    """
    echo -e "chr1\\t1000\\t1001\\tGene1\\t0\\t+" > tss.bed
    echo -e "chr1\\t2000\\t2001\\tGene2\\t0\\t-" >> tss.bed
    """
}