#!/usr/bin/env nextflow

/*
License issues
*/

/*
========================================================================================
                                CRISPR-seq DSL2
========================================================================================
 CRISPR-seq Analysis Pipeline.
 https://github.com/shuye2009/crispr-seq
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

chRawReads = Channel.fromPath(params.reads)
                    .map { file -> tuple(file.simpleName, file) }
                    .view {prefix, fileName -> "$prefix: $fileName"}

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

  chVersions | collectFile (storeDir: "$launchDir/results")
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