#!/usr/bin/env nextflow

process BEDTOOLS_MERGE {
    label 'process_single'
    container 'ghcr.io/bf528/bedtools:latest'
    publishDir "${params.outdir}/bedtools_merge", mode: 'copy'

    input:
    path(bed)

    output:
    path("merged_peaks.bed"), emit: merged

    script:
    """
    export TMPDIR=\${PWD}/tmp
    mkdir -p \${TMPDIR}
    cat $bed | sort -k1,1 -k2,2n > all_peaks.bed
    bedtools merge -i all_peaks.bed > merged_peaks.bed
    """

    stub:
    """
    touch merged_peaks.bed
    """
}