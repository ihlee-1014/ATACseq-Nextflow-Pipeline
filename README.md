# ATAC-Seq Nextflow Pipeline
Name: Iris Lee  
Date: 12/15/25  

The following README contains directions on how to run the project pipeline.

## README
This project is based on [Fernandes et al. 2024](https://www.cell.com/cell-reports/fulltext/S2211-1247(24)00636-3?_returnURL=https%3A%2F%2Flinkinghub.elsevier.com%2Fretrieve%2Fpii%2FS2211124724006363%3Fshowall%3Dtrue#fig6),
which is focused on chromatin accessibility as assayed by ATAC-seq. In this project, we generate an end-to-end pipeline for experiment and replicate some figures from the original paper.  

This repository consists of the following files:  

| File(s) | Path | Description |
| :------- | :------ | :------- |
| Nextflow Pipeline     | `main.nf` | Consists of a full Nextflow pipeline that processes the ATACseq data from Fernandes et al. 2024.    |
| Project Report  | `final-project-report.Rmd`   | Consists of the final project report.   |
| Project Report HTML | `final-project-report.html` | Consists of the project report in `.html` format. |
| RMarkdown Diffbind Analysis  | `final-project-diffbind.Rmd`   | Consists of an RMarkdown file that runs ATAC-seq Differential Accessibility Analysis with Diffbind.   |
| RMarkdown Diffbind Analysis HTML | `final-project-diffbind.html` | Consists of our Diffbind analysis in `.html` format. |
| RMarkdown Diffbind Analysis PDF | `final-project-diffbind.pdf` | Consists of our Diffbind analysis in `.pdf` format. |
| Samplesheet | `full_samplesheet.csv` | Consists of sample names and paths to all eight samples. Please change file paths if necessary. |
| Samples | `samples/` | Consists of samples downloaded from original publication. The folder in this repository is empty; please refer to notes below.* |
| Nextflow Modules | `modules/` | Consists of all Nextflow modules and their `main.nf` files used to run the pipeline. |
| References | `refs/` | Consists of all reference files, including adapter sequences, GRCm39 genome fasta and GTF file, and mm10 ENCODE blacklist. The folder in this repository only contains the adapter file; please refer to notes below.* |
| Results | `results/` | Consists of all plot images in project report. |
| Nextflow Configuration | `nextflow.config` | Consists of all parameters and settings used to run the Nextflow pipeline. |  

Steps to successfully run the pipeline:
1. Comment out everything past line 87 in `main.nf`. This contains everything before running R Diffbind. The command is:
```
nextflow run main.nf -profile singularity,local
```
2. After getting outputs from SAMTOOLS_IDX and MACS3_CALLPEAK, run the R Diffbind analysis.
3. After getting the `.bed` outputs from R Diffbind, uncomment everything past line 87 in `main.nf` and run:
```
nextflow run main.nf -profile singularity,local -resume
```

*All sample data were downloaded from the original publication via NIH's SRA Run Selector Accession [GSE266581](https://www.ncbi.nlm.nih.gov/Traces/study/?acc=GSE266581&o=acc_s%3Aa). 
Please download all eight `.fastq` files and upload them to the `samples/` folder before running the pipeline. Likewise, all reference data besides `ATACSeq-SE.fa` is not included in this repository. Please download the genome fasta and GTF files from [NIH's NCBI Genome Assembly GRCm39](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_000001635.27/) and the mm10 ENCODE blacklist region from the [Boyle Lab](https://github.com/Boyle-Lab/Blacklist) and upload them to the `refs` folder before running.  

Feel free to change any file paths if necessary.
