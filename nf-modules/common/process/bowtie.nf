/*
 * align the reads to TKO3 library
 */

process bowtie{
    label 'bowtie'
    label 'medCpu'
    label 'medMem'
    
    publishDir "$launchDir/results", mode: 'copy'
    
    input:
    tuple val(bf), path(processedReads)
    
    output:
    tuple val(bf), path("${bf}_aligned.tab"), emit: alignedReads
    tuple val(bf), path("${bf}_bowtie.log"), emit: bowtieLog
    tuple val(bf), path("${bf}_readCount.tab"), emit: readCount
    path("versions.txt"), emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    echo \$(bowtie --version | awk 'NR==1{print "bowtie "\$3}') > versions.txt

    trim5=0
    trim3=0
   
    localIndex=`find -L $projectDir -name "*.rev.1.ebwt" | sed 's/.rev.1.ebwt//'`
    zcat $processedReads | bowtie -v 2 -m 1 -p ${task.cpus} \
                -5 \${trim5} -3 \${trim3} \
                --un ${bf}_unaligned.fastq --sam-nohead \
                \${localIndex} - 2> "${bf}_bowtie.log" > ${bf}_aligned.tab

    cut -f3 ${bf}_aligned.tab | sort | uniq -c > ${bf}_readCount.tab


    """
}