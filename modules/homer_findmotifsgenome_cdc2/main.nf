#!/usr/bin/env nextflow

process FIND_MOTIFS_GENOME_CDC2 {
    label 'process_single'
    container 'ghcr.io/bf528/homer_samtools:latest'
    publishDir "${params.outdir}/findmotifsgenome", mode: "copy"

    input:
    tuple val(sample), path(bed)
    path(genome)

    output:
    path("cdc2_motifs")

    script:
    """
    findMotifsGenome.pl $bed $genome cdc2_motifs -size 200
    """

    stub:
    """
    mkdir cdc2_motifs
    """
}