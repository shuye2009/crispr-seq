#!/bin/bash

cmd=$HOME/Zuyao/crispr/scripts/pipeline.sh
wd=$HOME/Zuyao/crispr/Mar02_2020/Greenblatt
cd $wd
for f in *_R1_001.fastq.gz; do
	submitjob -m 5 $cmd $f $wd
done
