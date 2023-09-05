#!/bin/bash -euo pipefail
cd /mnt/c/RSYNC/Repositories/crispr-seq/results
for f in    Greenblatt_CPEB2_Sort_3_S3_R1_unmatched.fastq.gz                 Greenblatt_CPEB2_Sort_3_S3_R1_preProcessed.fastq.gz 	            Greenblatt_CPEB2_Sort_3_S3_R1_unaligned.fastq 	            Greenblatt_CPEB2_Sort_3_S3_R1_aligned.tab                 Greenblatt_CPEB2_Sort_3_S3_R1_readCount.tab                 Greenblatt_CPEB2_Sort_3_S3_R1_bowtie.log
do
    while [ -e $f ]; do rm $f; done
done
