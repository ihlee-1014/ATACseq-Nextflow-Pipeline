#!/usr/bin/env nextflow

process COMPUTEMATRIX_CDC1 {
    label 'process_high'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir "${params.outdir}/computematrix", mode: 'copy'

    input:
    path(bw)
    path(bed)
    val(window)

    output:
    path("cDC1_matrix.gz"), emit: matrix

    script:
    """
    computeMatrix reference-point \
        --referencePoint center \
        -b $window -a $window \
        -R $bed \
        -S $bw \
        -o cDC1_matrix.gz \
        --skipZeros \
        -p ${task.cpus}
    """

    stub:
    """
    touch cDC1_matrix.gz
    """
}