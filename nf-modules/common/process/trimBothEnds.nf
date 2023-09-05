/*
trimming stagger from the 5' end and adaptor from the 3' end of the reads
*/

process trimBothEnds{
    label 'perl'
    publishDir "$launchDir/results"
    
    input:
    tuple val(bf), path(reads)

    output:
    tuple val(bf), path("${bf}_unmatched.fastq.gz"),     emit: unMatched
    tuple val(bf), path("${bf}_preProcessed.fastq.gz"),  emit: preProcessed

    script:
    """
    zcat $reads | perl $projectDir/bin/preprocessReads_trimBothends.pl \
- 2> >(gzip > ${bf}_unmatched.fastq.gz) | gzip - > ${bf}_preProcessed.fastq.gz
    """
}
