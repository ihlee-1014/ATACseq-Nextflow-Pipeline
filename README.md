# BF 528 Fall 2025 Final Project README
Name: Iris Lee  
Date: 12/15/25  

Our final project is based on [Fernandes et al. 2024](https://www.cell.com/cell-reports/fulltext/S2211-1247(24)00636-3?_returnURL=https%3A%2F%2Flinkinghub.elsevier.com%2Fretrieve%2Fpii%2FS2211124724006363%3Fshowall%3Dtrue#fig6),
which is focused on chromatin accessibility as assayed by ATACseq. In this project, we generate an end-to-end pipeline for experiment and replicate some figures from the original paper.  

This repository consists of the following files:  

| File(s) | Path | Description |
| :------- | :------ | :------- |
| Nextflow Pipeline     | `main.nf` | Consists of a full Nextflow pipeline that processes the ATACseq data from Ferdandes et al. 2024    |
| RMarkdown Diffbind Analysis and Project Report  | `final-project-report.Rmd`   | Consists of an RMarkdown file that runs ATAC-seq Differential Accessibility Analysis with Diffbind, followed by a project report.   |
| Project Report HTML | `final-project-report.html` | Consists of our project report in `.html` format |
| Project Report PDF | `final-project-report.pdf` | Consists of our project report in `.pdf` format |
| Samplesheet | `full_samplesheet.csv` | Consists of sample names and paths to all eight samples |
| Samples | `samples/` | Consists of samples downloaded from original publication. The folder in this repository is empty; please refer to notes below on SRA* |
| Nextflow Modules | `modules/` | Consists of all Nextflow modules and their `main.nf` files used to run the pipeline |
| Adapter File | `refs/ATACSeq-SE.fa` | Consists of all adapter sequences used to run Trimmomatic |
| Nextflow Results | `results/` | Consists of all results from each Nextflow module |
| Nextflow Configuration | `nextflow.config` | Consists of all parameters and settings used to run the Nextflow pipeline |  

Steps to successfully run the pipeline:
1. Comment out everything past line 83 in `main.nf`. This contains everything before running R Diffbind. The command is:
```
nextflow run main.nf -profile singularity,local
```
2. After getting outputs from SAMTOOLS_IDX and MACS3_CALLPEAK, run the R Diffbind analysis.
3. After getting the `.bed` outputs from R Diffbind, uncomment everything past line 83 in `main.nf` and run:
```
nextflow run main.nf -profile singularity,local -resume
```

*All sample data were downloaded from the original publication via NIH's SRA Run Selector Accession [GSE266581](https://www.ncbi.nlm.nih.gov/Traces/study/?acc=GSE266581&o=acc_s%3Aa). 
Please download all eight `.fastq` files and upload them to the `samples/` folder before running the pipeline.
