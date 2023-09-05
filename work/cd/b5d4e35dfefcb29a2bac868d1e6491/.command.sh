#!/bin/bash -euo pipefail
zcat Greenblatt_CPEB2_Sort_1_S1_R1.fastq.gz | perl /mnt/c/RSYNC/Repositories/crispr-seq/bin/preprocessReads_trimBothends.pl - 2> >(gzip > Greenblatt_CPEB2_Sort_1_S1_R1_unmatched.fastq.gz) | gzip - > Greenblatt_CPEB2_Sort_1_S1_R1_preProcessed.fastq.gz
