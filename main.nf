#!/usr/bin/env nextflow

/*
Copyright Institut Curie 2020-2021
This software is a computer program whose purpose is to analyze high-throughput sequencing data.
You can use, modify and/ or redistribute the software under the terms of license (see the LICENSE file for more details).
The software is distributed in the hope that it will be useful, but "AS IS" WITHOUT ANY WARRANTY OF ANY KIND.
Users are therefore encouraged to test the software's suitability as regards their requirements in conditions enabling the security of their systems and/or data.
The fact that you are presently reading this means that you have had knowledge of the license and that you accept its terms.
*/

/*
========================================================================================
                                ChIP-seq DSL2
========================================================================================
 ChIP-seq Analysis Pipeline.
 https://gitlab.curie.fr/data-analysis/chip-seq
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl=2

/*
==========================
 BUILD CHANNELS
==========================
*/

chSingleEnd   = Channel.value(params.singleEnd) 
chGuideLib    = params.guideLib     ? Channel.fromPath(params.guideLib, checkIfExists: true).collect()    : Channel.empty()
chMetadata    = params.metadata     ? Channel.fromPath(params.metadata, checkIfExists: true).collect()    : Channel.empty()
chDesignFile  = params.design       ? Channel.fromPath(params.design, checkIfExists: true).collect()      : Channel.empty()



/*
==============================
  LOAD INPUT DATA
==============================
*/

// Load raw reads

chRawReads = Channel.fromPath(params.reads).map { file -> tuple(file.simpleName, file) }

// Make samplePlan if not available
//chSplan = NFTools.getSamplePlan(params.samplePlan, params.reads, params.readPaths, params.singleEnd)

// Design
//chDesignControl = params.design ? loadDesign(params.design) : Channel.empty()

/*
==================================
           INCLUDE
==================================
*/ 

// Workflows

// Processes
include { checkDesign } from './nf-modules/local/process/checkDesign'
include { fastqc }      from './nf-modules/common/process/fastqc'
include { trimBothEnds }  from './nf-modules/common/process/trimBothEnds'
include { bowtie }      from './nf-modules/common/process/bowtie'
include { readCounts }       from './nf-modules/common/process/readCounts'
include { readStats }       from './nf-modules/common/process/readStats'
include { alignStats }       from './nf-modules/common/process/alignStats'
include { cleanup }       from './nf-modules/common/process/cleanup'

include { getSoftwareVersions } from './nf-modules/common/process/utils/getSoftwareVersions'
include { outputDocumentation } from './nf-modules/common/process/utils/outputDocumentation'
//include { multiqc }             from './nf-modules/local/process/multiqc'

workflow {
  chVersions = Channel.empty()

  //*******************************************
  // PROCESS: fastqc
  if(!params.skipFastqc){
    fastqc (
      chSingleEnd, chRawReads
    )
  }
  
  chFastqcMqc = fastqc.out.results.collect()
  chVersions = chVersions.mix(fastqc.out.versions)
  //chVersions.view {"fastqc version", $it}

  //*******************************************
  // TRIMMING STAGGER AND ADAPTOR
  trimBothEnds (
    chRawReads
  )

  chProcessedReads = trimBothEnds.out.preProcessed

  //*******************************************
  // ALIGN TO TKO
  bowtie (
    chProcessedReads
  )

  chCounts = bowtie.out.readCount
  chVersions = chVersions.mix(bowtie.out.versions)

  //*******************************************
  // COUNT ALIGNED READS PER GENE PER GUIDE
  readCounts (
    chCounts, chGuideLib
  )

  //*******************************************
  // GET INPUT FASTQ SIZE
  readStats (chRawReads) | collectFile (storeDir: "$launchDir/results")

  //*******************************************
  // COLLECT ALIGNMENT STATS
  chUnmatched = trimBothEnds.out.unMatched
  chBowtieLog = bowtie.out.bowtieLog
  alignStats (chUnmatched, chBowtieLog) | collectFile (storeDir: "$launchDir/results")

  //*******************************************
  // CLEANUP
  if(!params.saveIntermediates){
    cleanup (
      chRawReads
    )
  }
}
  

/*
  
  trimBothEnds(
    chRawReads
  )
  
  chProcessed = trimBothEnds.out.preProcessed
  chProcessed.view {"processed reads: $it"}
  

  bowtie(
    chProcessed
  )
  chVersions = chVersions.mix(bowtie.out.versions)
*/