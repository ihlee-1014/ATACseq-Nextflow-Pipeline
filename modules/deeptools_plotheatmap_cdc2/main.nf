#!/usr/bin/env nextflow

process PLOTHEATMAP_CDC2 {
    label 'process_medium'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir "${params.outdir}/plotheatmap", mode: 'copy'

    input:
    path(matrix)

    output:
    path("cDC2_heatmap.png"), emit: heatmap
    path("cDC2_clusters.bed"), emit: clusters

    script:
    """
    plotHeatmap -m $matrix \
        -o cDC2_heatmap.png \
        --kmeans 3 \
        --colorMap Blues \
        --whatToShow 'heatmap and colorbar' \
        --refPointLabel "center" \
        --outFileSortedRegions cDC2_clusters.bed
    """

    stub:
    """
    touch cDC2_heatmap.png
    touch cDC2_clusters.bed
    """
}