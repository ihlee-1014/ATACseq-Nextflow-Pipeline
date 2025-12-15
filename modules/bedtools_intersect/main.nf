#!/usr/bin/env nextflow

process BEDTOOLS_INTERSECT {
    label 'process_single'
    container 'ghcr.io/bf528/bedtools:latest'
    publishDir "${params.outdir}/bedtools_intersect", mode: "copy"

    input:
    tuple val(sample1), path(bam), path(bai), val(sample2), path(peaks)

    output:
    tuple val(sample1), path("${sample1}_reads_in_peaks.txt"), emit: counts

    script:
    """
    bedtools intersect -a $peaks -b $bam -c -bed > ${sample1}_reads_in_peaks.txt
    """

    stub:
    """
    touch ${sample}_reads_in_peaks.txt
    """
}