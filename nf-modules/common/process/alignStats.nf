/*
 * collect alignment stats
 */

 process alignStats {
    
    input:
    tuple val(bf), path(unmatched)
    tuple val(bf), path(bowtieLog)

    output:
    path("preprocess_and_alignment_stats.txt"),     emit: stats
    
    script:
    """
    echo -e "\n**** $bf ****" > preprocess_and_alignment_stats.txt
    zcat $unmatched | tail -n 20 >> preprocess_and_alignment_stats.txt
	cat $bowtieLog >> preprocess_and_alignment_stats.txt

    """
 }