#!/bin/bash -euo pipefail
echo $(bowtie --version | awk 'NR==1{print "bowtie "$3}') > versions.txt

trim5=0
trim3=0

localIndex=`find -L /mnt/c/RSYNC/Repositories/crispr-seq -name "*.rev.1.ebwt" | sed 's/.rev.1.ebwt//'`
zcat Greenblatt_CPEB2_Sort_1_S1_R1_preProcessed.fastq.gz | bowtie -v 2 -m 1 -p 1                 -5 ${trim5} -3 ${trim3}                 --un Greenblatt_CPEB2_Sort_1_S1_R1_unaligned.fastq --sam-nohead                 ${localIndex} - 2> "Greenblatt_CPEB2_Sort_1_S1_R1_bowtie.log" > Greenblatt_CPEB2_Sort_1_S1_R1_aligned.tab

cut -f3 Greenblatt_CPEB2_Sort_1_S1_R1_aligned.tab | sort | uniq -c > Greenblatt_CPEB2_Sort_1_S1_R1_readCount.tab
