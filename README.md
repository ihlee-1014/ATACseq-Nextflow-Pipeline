# BF 528 Fall 2025 Final Project
Name: Iris Lee  
Date: 12/15/25  

The following README contains directions on how to run the project pipeline, followed by a project report.

## README
Our final project is based on [Fernandes et al. 2024](https://www.cell.com/cell-reports/fulltext/S2211-1247(24)00636-3?_returnURL=https%3A%2F%2Flinkinghub.elsevier.com%2Fretrieve%2Fpii%2FS2211124724006363%3Fshowall%3Dtrue#fig6),
which is focused on chromatin accessibility as assayed by ATAC-seq. In this project, we generate an end-to-end pipeline for experiment and replicate some figures from the original paper.  

This repository consists of the following files:  

| File(s) | Path | Description |
| :------- | :------ | :------- |
| Nextflow Pipeline     | `main.nf` | Consists of a full Nextflow pipeline that processes the ATACseq data from Ferdandes et al. 2024.    |
| RMarkdown Diffbind Analysis  | `final-project-diffbind.Rmd`   | Consists of an RMarkdown file that runs ATAC-seq Differential Accessibility Analysis with Diffbind.   |
| RMarkdown Diffbind Analysis HTML | `final-project-diffbind.html` | Consists of our Diffbind analysis in `.html` format. |
| RMarkdown Diffbind Analysis PDF | `final-project-diffbind.pdf` | Consists of our Diffbind analysis in `.pdf` format. |
| Samplesheet | `full_samplesheet.csv` | Consists of sample names and paths to all eight samples. Please change file paths if necessary. |
| Samples | `samples/` | Consists of samples downloaded from original publication. The folder in this repository is empty; please refer to notes below.* |
| Nextflow Modules | `modules/` | Consists of all Nextflow modules and their `main.nf` files used to run the pipeline. |
| References | `refs/` | Consists of all reference files, including adapter sequences, GRCm39 genome fasta and GTF file, and mm10 ENCODE blacklist. The folder in this repository only contains the adapter file; please refer to notes below.* |
| Nextflow Results | `results/` | Consists of all results from each Nextflow module. |
| Nextflow Configuration | `nextflow.config` | Consists of all parameters and settings used to run the Nextflow pipeline. |  

Steps to successfully run the pipeline:
1. Comment out everything past line 85 in `main.nf`. This contains everything before running R Diffbind. The command is:
```
nextflow run main.nf -profile singularity,local
```
2. After getting outputs from SAMTOOLS_IDX and MACS3_CALLPEAK, run the R Diffbind analysis.
3. After getting the `.bed` outputs from R Diffbind, uncomment everything past line 85 in `main.nf` and run:
```
nextflow run main.nf -profile singularity,local -resume
```

*All sample data were downloaded from the original publication via NIH's SRA Run Selector Accession [GSE266581](https://www.ncbi.nlm.nih.gov/Traces/study/?acc=GSE266581&o=acc_s%3Aa). 
Please download all eight `.fastq` files and upload them to the `samples/` folder before running the pipeline. Likewise, all reference data besides `ATACSeq-SE.fa` is not included in this repository. Please download the genome fasta and GTF files from [NIH's NCBI Genome Assembly GRCm39](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_000001635.27/) and the mm10 ENCODE blacklist region from the [Boyle Lab](https://github.com/Boyle-Lab/Blacklist) and upload them to the `refs` folder before running.  

Feel free to change any file paths if necessary.

## Final Project Report

### Quality Control Evaluation & Alignment Statistics

Based on the MultiQC report and accompanying QC metrics from FASTQC, Trimmomatic, and `samtools flagstat`, the sequencing reads appear to be of generally high quality. FASTQC flagged no major quality issues aside from duplication levels, which ranged from 14.8%-25.0% across samples due to modest library complexity or samples containing substantial open chromatin regions. Samples had very minimal adapter contamination (<0.12%). Nextera transposase adapters were successfully removed via Trimmomatic, and FASTQ was run after Trimmomatic to minimize adapter detection. Trimmomatic performance was strong, with high percentages of surviving reads across all samples (close to 100%). MultiQC detected only two overrepresented sequences in the cDC1 samples, each present at low levels (<1%), suggesting no substantial contamination or artifact. Based on this evaluation, we believe that the sequence runs and library preparations were successful, and the experiment was of high quality and thus suitable for downstream analyses.

 Below is a table outlining total numbers as well as percentages of mapped reads based on `samtools flagstat`:  

| Sample Name    | Mapped Reads | % of Mapped Reads |
| -------- | ------- | ------- |
| KO1_rep1  |  | % |
| KO2_rep1 |  | % |
| WT1_rep1 |  | % |
| WT2_rep1 |  | % |
| KO1_rep2  |  | % |
| KO2_rep2 |  | % |
| WT1_rep2 |  | % |
| WT2_rep2 |  | % |

Alignment metrics reveal that 

### QC Metrics
- Heatmap of signal across TSS split between NFR and NBR
- Fraction of Reads in Peak (FRiP)

Comment, in no less than a paragraph, on each of your chosen two ATAC-seq QC metrics and what they mean about the success of the experiment.

### Peaks & Enrichment Analysis
- Report how many differentially accessible regions your pipeline discovered in each of the two conditions.
- A figure showing the enrichment results of the differentially accessible regions and a few sentences describing what the enrichment reveals.
- A figure showing the motif enrichment results from the differential peaks and a few sentences describing the key motifs found.
- Comment on the success of the reproductions of the panels from the original publication. Do you think the results are consistent with the original publication? What do your results show that is different from the original publication?
