/*
 * collect raw read stats
 */

 process readStats {
    
    input:
    tuple val(bf), path(reads)


    output:
    path("fastq_raw_reads_count.tab"),              emit: totalReads
    
    script:
    """
    count=\$(zcat $reads |grep "@" | wc -l)
	echo -e "$bf\t\$count" > fastq_raw_reads_count.tab

    """
 }