#!/usr/bin/env nextflow

process BEDTOOLS_REMOVE {
    label 'process_single'
    container 'ghcr.io/bf528/bedtools:latest'
    publishDir "${params.outdir}/bedtools_remove", mode: "copy"

    input:
    tuple val(sample), path(peaks)
    path(blacklist)

    output:
    tuple val(sample), path("${sample}_filtered.bed"), emit: filtered

    script:
    """
    bedtools subtract -a $peaks -b $blacklist > ${sample}_filtered.bed
    """

    stub:
    """
    touch ${sample}_filtered.bed
    """
}