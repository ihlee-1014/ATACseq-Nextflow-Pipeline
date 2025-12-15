#!/usr/bin/env nextflow

process PLOTHEATMAP_CDC1 {
    label 'process_medium'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir "${params.outdir}/plotheatmap", mode: 'copy'

    input:
    path(matrix)

    output:
    path("cDC1_heatmap.png"), emit: heatmap
    path("cDC1_clusters.bed"), emit: clusters

    script:
    """
    plotHeatmap -m $matrix \
        -o cDC1_heatmap.png \
        --kmeans 3 \
        --colorMap Blues \
        --whatToShow 'heatmap and colorbar' \
        --refPointLabel "center" \
        --outFileSortedRegions cDC1_clusters.bed
    """

    stub:
    """
    touch cDC1_heatmap.png
    touch cDC1_clusters.bed
    """
}