/*
 * FastQC - Quality controls on raw reads
 */

process fastqc {
  
  label 'fastqc'
  label 'medCpu'
  label 'lowMem'

  publishDir "$launchDir/results", mode: 'copy'

  input:
  val(singleEnd)
  tuple val(bf), path(reads)

  output:
  path("${bf}_fastqc.{zip,html}"),  emit: results
  path("versions.txt"),             emit: versions

  when:
  task.ext.when == null || task.ext.when

  script:

  if (singleEnd){
    """
    echo \$(fastqc --version) > versions.txt
    [ ! -f  ${bf}.gz ] && ln -s $reads ${bf}.gz
    fastqc -q ${bf}.gz --threads ${task.cpus}
    """
  }else{
    """
    echo \$(fastqc --version) > versions.txt
    [ ! -f  ${bf}_1.fastq.gz ] && ln -s ${reads[0]} ${bf}_1.fastq.gz
    [ ! -f  ${bf}_2.fastq.gz ] && ln -s ${reads[1]} ${bf}_2.fastq.gz
    fastqc -q --threads ${task.cpus} ${bf}_1.fastq.gz ${bf}_2.fastq.gz
    """
  }
}
