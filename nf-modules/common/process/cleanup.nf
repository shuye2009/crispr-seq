/*
 * remove intermediate files to save space
 */

 process cleanup{
    input:
    tuple val(bf), path(reads)

    """
    cd $launchDir/results
    for f in    ${bf}_unmatched.fastq.gz \
                ${bf}_preProcessed.fastq.gz \
	            ${bf}_unaligned.fastq \
	            ${bf}_aligned.tab \
                ${bf}_readCount.tab \
                ${bf}_bowtie.log
    do
        while [ -e \$f ]; do rm \$f; done
    done
    
    """
 }