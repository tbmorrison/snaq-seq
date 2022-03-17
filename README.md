# SNAQ-SEQ CLI QC tool for viral surveillance NGS testing. 

Table of Contents
-----------------
- [Introduction](#introduction)
- [Command Line Interphase](#cli)
- [System requirements](#requirements)
- [Input data](#data)
  1. [Reference genome](#reference-genome)
  2. [Reference amplicon](#reference-amplicon)
  3. [Adjustment amplicon](#adjustment-amplicon)
- [Usage](#usage-options)
- [Docker container](#docker)

## <a name="introduction"></a> Introduction-

[AccuGenomics](https://accugenomics.com/) patented and propriety technology, Standardized Nucleic Acid Quantification for Sequencing (SNAQ™-SEQ) is an innovative method that utilizes synthetic DNA or RNA internal standards mixtures (ISM™) that are spiked into each sample prior to extraction or NGS library preparation steps. These ISMs are the most optimal way of controlling for variation within the result and are the gold standard method for sensitive bioanalyte measurements.

This unique spike-in control technology dramatically improves the accuracy and performance of clinical sequencing tests for low abundance biomarkers such as circulating tumor DNA (ctDNA) and low titer infectious pathogens such as SARS-CoV-2.

The ISMs undergo the same processing, handling and reaction conditions as the sample does, to provide the ideal run control approach for NGS-based assays.

## <a name="cli"></a> Command Line Interphase-

The SNAQ-SEQ Command Line Interphase is an open source tool that simplifies viral surveillance by NGS. This is a complex test that uses various sequencing metrics (e.g., genomic coverage x read depth) to detect testing failures.  SNAQ-SEQ SARS-CoV-2 RNA Internal Standards (IS) are spiked into every sample and provides missing QC to detect NGS test issues.

To minimize disruption to a bioinformatic pipeline, the SNAQ-SEQ CLI replaces a common step: the removal of human reads prior to further processing.

The CLI will input one FASTQ input and output Viral (NT), and SNAQ-SEQ analysis appended to a CSV file.  The CSV will contain samples in rows and columns indicating SNAQ analysis results for coverage, read depth, viral load, recombination, and complexity capture.

Parameters indicate path to input and output files, along with IS spike-in analysis parameters. The CLI runs as a container to simplify deployment.

Instruct the user to utilize the SNAQ-SEQ container on their specific samples.

## <a name="requirements"></a> System requirements-

SNAQ-SEQ only supports Linux systems and uses the docker application. 

If docker is not installed, the beta version will attempt to set up docker that will require sudo (admin) priveleges. 

SNAQ-SEQ will verfiy both system requirements before proceeding.

```

$ bash snaq-seq.sh input=/home/input/fastq output=/home/output rg=/home/input/ref bc=/home/input/amplicon_basechange.txt norm=/home/input/normalization.txt outputSAM=0 ofsCutoff=0.01 mfs=0 RC=1 mapq=-1 qCutoff=0  gbc=1 outputIS=0 CC=300 IS=300

Linux system verified...

Docker application verified... 
``` 

## <a name="data"></a> Input data-

#### Reference genome:

SNAQ-SEQ uses the bwa aligner for the analysis which requires the reference genome (fasta format) and bwa indices. 

SNAQ-SEQ will verify if there are existing bwa indices made available that can be used for the analysis.


* Note: If SNAQ-SEQ is unable to detect any bwa indices in the filepath provided, it will proceed with generating indices on the fly to be used for the analysis (the generated indices won't be saved).


#### Reference amplicon:

The basechange amplicon is required to be provided in txt format. The preliminary step includes how to generate it.

#### Adjustment amplicon:

The adjustment (normalization) amplicon is required to be provided in tab seperated format used to generate result values in the output.

## <a name="usage-options"></a> Usage-

For information about usage and options, run ```bash snaq-seq.sh -h```: 

All options are required to run the analysis.

```
$ bash snaq-seq.sh -h
 
     Snaq-Seq: QC for viral surveillance NGS testing.     

Usage: bash snaq-seq.sh input=/home/input/fastq/ output=/home/output rg=/home/input/ref/genome.fasta bc=/home/input/amplicon_basechange.txt norm=/home/input/normalization.txt outputSAM=0 ofsCutoff=0.01 mfs=0 RC=1 mapq=-1 qCutoff=0  gbc=1 outputIS=0 CC=300 IS=300
```

## Parameters:

Command line parameters will indicate path to input and output files, along with IS spike-in analysis parameters. There are a total of 15 parameters (3 filepaths, 2 filenames, 10 integer values) to be provided in the following order on the command line:
 
1)  input=                  Location folder path to fastq files, folders should only consist of fastq files.
2)  output=                 Location folder path to place analysis outputs.
3)  rg=       	            Location file path of reference genome (fasta format). The path must include bwa indices. The reference genome must also have:
  - host/background, e.g., hg19 
  - IS amplicons (contig ID tagged with - SNAQ-IS) 
  - NT amplicons (contig ID with -SNAQ-NT) 
  - CC amplicons (contig ID tagged with -SNAQ-CC) 
4)  bc=                     Location file path of basechange file.
5)  norm=                   Location file path of IS amplicon adjustment (normalization) file (tab seperated format).
6)  outputSAM=              Alignment output in SAM format (0=False, 1=True).
7)  ofsCutoff=              offspring Cutoff (float value).
8)  mfs=                    Minimum fragment size: minimum fragment length for good read (integer value).
9)  RC=                     Recombinant detection stringency: indicates how many recombinant bases allowed per read pair (integer value).
10) mapq=                   Mapping quality stringency (integer value).
11) qCutoff=                Minimum Q score for good read (integer value).
12) gbc=                    Number of base change positions in a fragment for it to be considered valid (integer value).
13) outputIS=               Include IS sequences in fastq output (integer value).
14) CC=                     Number of complexity control copies spiked into the sample (integer value).
15) IS=                     Internal standards input copies: number of IS copies spiked into the sample. If value is zero, don’t perform coverage analysis or viral load (integer value)
16) VERSION=                Docker container version (string).


Snaq-seq will  verify if the options were provided appropriately before proceeding.

```
$ bash snaq-seq.sh input=/home/input/fastq output=/home/output rg=/home/input/ref/genome.fasta bc=/home/input/amplicon_basechange.txt norm=/home/input/normalization.txt outputSAM=0 ofsCutoff=0.01 mfs=0 RC=1 mapq=-1 qCutoff=0  gbc=1 outputIS=0 CC=300 IS=300 VERSION=v1


input=/home/input/fastq
output=/home/output
rg=/home/input/reference/genome.fasta
bc=/home/input/amplicon_basechange.txt
norm=/home/input/normalization.txt
outputSAM=0
ofsCutoff=0.01
mfs=0
RC=1
mapq=-1
qCutoff=0
gbc=1
outputIS=0
CC=300
IS=300
VERSION=v1
```
## <a name="docker"></a> Docker Container-

The SNAQ-SEQ pipeline is in a public container located on [DockerHub](https://hub.docker.com/r/accugenomics/snaq-seq).