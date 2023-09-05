#!/bin/bash -euo pipefail
echo $(fastqc --version) > versions.txt
[ ! -f  Greenblatt_CPEB2_Sort_4_S4_R1.gz ] && ln -s Greenblatt_CPEB2_Sort_4_S4_R1.fastq.gz Greenblatt_CPEB2_Sort_4_S4_R1.gz
fastqc -q Greenblatt_CPEB2_Sort_4_S4_R1.gz --threads 4
