#!/usr/bin/env nextflow

process ANNOTATE_CDC2 {
    label 'process_single'
    container 'ghcr.io/bf528/homer_samtools:latest'
    publishDir "${params.outdir}/annotatepeaks", mode: "copy"

    input:
    tuple val(sample), path(bed)
    path(genome)
    path(gtf)

    output:
    path("cdc2_annotated_peaks.txt")

    script:
    """
    annotatePeaks.pl $bed $genome -gtf $gtf > cdc2_annotated_peaks.txt
    """

    stub:
    """
    touch cdc2_annotated_peaks.txt
    """
}