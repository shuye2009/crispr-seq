/* 
 * Mapping Worflow
 * Able to align both on reference and spike genomes
 */


if (params.aligner == "bwa-mem"){
  include { bwaMem as mappingRef } from '../../common/process/bwa/bwaMem'
  include { bwaMem as mappingSpike } from '../../common/process/bwa/bwaMem'
}else if (params.aligner == "bowtie2"){
  include { bowtie2 as mappingRef } from '../../common/process/bowtie2/bowtie2'
  include { bowtie2 as mappingSpike } from '../../common/process/bowtie2/bowtie2'
}else if (params.aligner == "star"){
  include { starAlign as mappingRef } from '../../common/process/star/starAlign'
  include { starAlign as mappingSpike } from '../../common/process/star/starAlign'
}

include { compareBams } from '../../local/process/compareBams'
include { samtoolsSort as samtoolsSortRef } from '../../common/process/samtools/samtoolsSort'
include { samtoolsSort as samtoolsSortSpike } from '../../common/process/samtools/samtoolsSort'
include { samtoolsIndex as samtoolsIndexRef } from '../../common/process/samtools/samtoolsIndex'
include { samtoolsIndex as samtoolsIndexSpike } from '../../common/process/samtools/samtoolsIndex'
include { samtoolsFlagstat } from '../../common/process/samtools/samtoolsFlagstat'

workflow mappingFlow {

  take:
  reads
  indexRef
  indexSpike

  main:
  chVersions = Channel.empty()
  

  // Align on reference genome
  if (params.aligner == "star"){
    mappingRef(
      reads,
      indexRef.collect(),
      Channel.empty().collect().ifEmpty([])
    )
  }else{
    mappingRef(
      reads,
      indexRef.collect()
    )
  }
  chVersions = chVersions.mix(mappingRef.out.versions)

  if (params.spike){
    // Align on spike genome
    if (params.aligner == "star"){
      mappingSpike(
        reads,
        indexSpike.collect(),
        Channel.empty().collect().ifEmpty([])
      )
    }else{
      mappingSpike(
        reads,
        indexSpike.collect()
      )
    }

    // Compare reference/spike mapping
    compareBams(mappingRef.out.bam.join(mappingSpike.out.bam), params.genome, params.spike)

    chRefBam = compareBams.out.refBam
    chSpikeBam = compareBams.out.spikeBam
    chCompareBamsMqc = compareBams.out.mqc
    chSpikeLogs = mappingSpike.out.logs
  }else{
    chRefBam = mappingRef.out.bam
    chSpikeBam = Channel.empty()
    chCompareBamsMqc = Channel.empty()
    chSpikeLogs = Channel.empty()
  }
 
  // Process reference bams
  samtoolsSortRef(
    chRefBam
  )
  chVersions = chVersions.mix(samtoolsSortRef.out.versions)

  samtoolsIndexRef(
    samtoolsSortRef.out.bam
  )
  chVersions = chVersions.mix(samtoolsIndexRef.out.versions)

  samtoolsFlagstat(
   samtoolsSortRef.out.bam
  )
  chVersions = chVersions.mix(samtoolsFlagstat.out.versions)

  // Process spike bams
  if (params.spike){
    samtoolsSortSpike(
      chSpikeBam
    )

    samtoolsIndexSpike(
      samtoolsSortSpike.out.bam
    )
    chSpikeBamOutput=samtoolsSortSpike.out.bam.join(samtoolsIndexSpike.out.bai)
  }else{
    chSpikeBamOutput=Channel.empty()
  }

  emit:
  bam = samtoolsSortRef.out.bam.join(samtoolsIndexRef.out.bai)
  logs = mappingRef.out.logs
  flagstat = samtoolsFlagstat.out.stats
  spikeBam = chSpikeBamOutput
  spikeLogs = chSpikeLogs
  compareBamsMqc = chCompareBamsMqc
  versions = chVersions
}
