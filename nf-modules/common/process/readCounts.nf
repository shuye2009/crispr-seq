/*
 * Count reads for each gene, separated by each guide
 */

 process readCounts {
    label 'perl'
    publishDir "$launchDir/results", mode: 'copy'
    
    input:
    tuple val(bf), path(readCount)
    path(guideLib)

    output:
    tuple val(bf), path("${bf}_guideRawCount.tab"),     emit: guideCount
    tuple val(bf), path("${bf}_geneRawCount.tab"),      emit: geneCount

    script:
    """
    perl $projectDir/bin/countReads_perGuide.pl $readCount ${bf}_guideRawCount.tab F $guideLib > ${bf}_geneRawCount.tab

    """
 }