#!/bin/bash -euo pipefail
perl /mnt/c/RSYNC/Repositories/crispr-seq/bin/countReads_perGuide.pl Greenblatt_CPEB2_Sort_4_S4_R1_readCount.tab Greenblatt_CPEB2_Sort_4_S4_R1_guideRawCount.tab F TKOv2.1-Human-Library.txt > Greenblatt_CPEB2_Sort_4_S4_R1_geneRawCount.tab
