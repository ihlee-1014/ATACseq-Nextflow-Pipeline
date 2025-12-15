#!/usr/bin/env nextflow

process FIND_MOTIFS_GENOME_CDC1 {
    label 'process_single'
    container 'ghcr.io/bf528/homer_samtools:latest'
    publishDir "${params.outdir}/findmotifsgenome", mode: "copy"

    input:
    tuple val(sample), path(bed)
    path(genome)

    output:
    path("cdc1_motifs")

    script:
    """
    findMotifsGenome.pl $bed $genome cdc1_motifs -size 200
    """

    stub:
    """
    mkdir cdc1_motifs
    """
}