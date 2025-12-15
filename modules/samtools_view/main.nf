#!/usr/bin/env nextflow

process SAMTOOLS_VIEW {
    label 'process_single'
    container 'ghcr.io/bf528/samtools:latest'
    publishDir "${params.outdir}/samtools_view", mode: 'copy'

    input:
    tuple val(sample), path(bam)

    output:
    tuple val(sample), path("*.noMT.bam"), emit: filtered

    script:
    """
    samtools view -b -e 'rname != "chrM" && rname != "MT" && rname != "M" && rname != "chrMT"' $bam -o ${sample}.noMT.bam
    """

    stub:
    """
    touch ${sample}.stub.noMT.bam
    """
}