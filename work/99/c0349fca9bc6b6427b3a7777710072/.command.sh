#!/bin/bash -euo pipefail
echo -e "
**** Greenblatt_CPEB2_Sort_2_S2_R1 ****" > preprocess_and_alignment_stats.txt
    zcat Greenblatt_CPEB2_Sort_4_S4_R1_unmatched.fastq.gz | tail -n 20 >> preprocess_and_alignment_stats.txt
	cat Greenblatt_CPEB2_Sort_2_S2_R1_bowtie.log >> preprocess_and_alignment_stats.txt
