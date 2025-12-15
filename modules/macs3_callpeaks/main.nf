#!/usr/bin/env nextflow

process CALLPEAKS {
    label 'process_high'
    container 'ghcr.io/bf528/macs3:latest'
    publishDir "${params.outdir}/macs3_callpeaks", mode: 'copy'

    input:
    tuple val(sample), path(bam), path(bai)

    output:
    tuple val(sample), path("${sample}_peaks.narrowPeak"), emit: peaks
    tuple val(sample), path("${sample}_summits.bed"), emit: summits
    
    script:
    """
    macs3 callpeak -f BAM -t $bam -g hs -n $sample -B -q 0.01 \
        --shift -50 --extsize 100 --nomodel --keep-dup all
    """

    stub:
    """
    touch ${sample}_peaks.narrowPeak
    touch ${sample}_summits.bed
    """
}