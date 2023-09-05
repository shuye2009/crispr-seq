#!/bin/bash -euo pipefail
count=$(zcat Greenblatt_CPEB2_Sort_1_S1_R1.fastq.gz |grep "@" | wc -l)
echo -e "Greenblatt_CPEB2_Sort_1_S1_R1	${count}" > fastq_raw_reads_count.tab
