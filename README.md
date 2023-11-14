# crispr-seq

usage (run in launch directory):
nextflow run ~/crispr-seq/main.nf -profile conda,cluster -resume
nextflow run ~/crispr-seq/main.nf -resume --tidyup true

This pipeline is adapted from:
https://gitlab.curie.fr/data-analysis/chip-seq