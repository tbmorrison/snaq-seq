# SNAQ-Vsoft CLI QC tool for viral surveillance NGS testing. 

Table of Contents
-----------------
- [Introduction](#introduction)
- [Command Line Interface](#command-line-interface)
- [System requirements](#requirements)
- [Input data](#data)
- [Usage](#usage-options)
- [Docker container](#docker)

## <a name="introduction"></a> Background-

[AccuGenomics](https://accugenomics.com/) patented and propriety technology, Standardized Nucleic Acid Quantification for Sequencing (SNAQ™-SEQ) is an innovative method that utilizes synthetic DNA or RNA internal standards mixtures (IS) that are spiked into each sample prior to extraction or NGS library preparation steps. These IS are the most optimal way of controlling for variation within the result and are the gold standard method for sensitive bioanalyte measurements.

This unique spike-in control technology dramatically improves the accuracy and performance of clinical sequencing tests for low abundance biomarkers such as circulating tumor DNA (ctDNA) and low titer infectious pathogens such as SARS-CoV-2.

The IS are designed to biochemically mimic the target analytes, matching the target nucleic acid sequence with the exception of engineered base changes that allow bioinformatic separation of IS from sample reads.  The IS are mixed with sample at a steps prior nucleic acid purification or with the purified nucleic acids just prior to entry into the library preparation.  SNAQ analysis improve NGS test results as it provides missing quality controls for read bias, complexity capture, duplication rates, NGS sequencing error. The SNAQ-Vsoft package was designed to support viral survalence testing by providing needed viral load standardization and coverage.  The SNAQ-Vsoft CLI described herein performs the SNAQ-SEQ analysis while striping away the non-sample reads. The SNAQ-SEQ analysis may be used in user's bioinformatic pipelines, or visualized using the AccuGenomics SNAQ-Vsoft GUI package.

## <a name="command-line-interface"></a> Command Line Interface-

The SNAQ-Vsoft Command Line Interface is an open source tool that performs SNAQ analysis on viral sequencing data that incorporate the SNAQ-SEQ IS.  SNAQ-SEQ provides needed quality controls (e.g., genomic coverage, viral load, complexity capture) in support of accurate viral surveillance by NGS. While this script was originally developed for the SARS-CoV-2 Accukit MN (Midnight) RNA Internal Standards (IS), it is compatible with other AccuGenomics viral IS.   

To minimize disruption to a bioinformatic pipeline, the SNAQ-SEQ CLI replaces a common step in survalence bioinformatic pipeline: the removal of human reads prior to further processing. The default CLI settings will input one FASTQ input, expected to contain viral, human and IS reads, and output viral reads FASTQ (NT), and SNAQ-SEQ analysis in comma separated (CSV) file format file.  The CSV will contain samples in rows and columns indicating SNAQ analysis results for coverage, read depth, viral load, recombination, and complexity capture.

Users interact with the SNAQ-Vsoft through command line parameters such as input and output FASTQ file paths, or IS spike-in levels. The CLI runs as a container to simplify deployment.  A full list of parameters is obtained using --help.

## <a name="requirements"></a> System requirements-

The current version of SNAQ-Vsoft CLI has only been tested on Linux systems using the docker application. 

SNAQ-Vsoft CLI will verfiy both system requirements before proceeding as depicted in the example below.

The SNAQ-Vsoft Command Line Interface (SNAQ-Vsoft CLI) is an open source tool that simplifies viral surveillance by NGS. This is a complex test that uses various sequencing metrics (e.g., genomic coverage x read depth) to detect testing failures.  SNAQ-SEQ SARS-CoV-2 RNA Internal Standards (IS) are spiked into every sample and provides missing QC to detect NGS test issues.

To minimize disruption to a bioinformatic pipeline, the SNAQ-Vsoft CLI replaces a common step: the removal of human reads prior to further processing.

The CLI will input one FASTQ input and output Viral (NT), and SNAQ-Vsoft CLI analysis appended to a CSV file.  The CSV will contain samples in rows and columns indicating SNAQ analysis results for coverage, read depth, viral load, recombination, and complexity capture.

Parameters indicate path to input and output files, along with IS spike-in analysis parameters. The CLI runs as a container to simplify deployment.

Instruct the user to utilize the SNAQ-Vsoft CLI container on their specific samples.

## <a name="requirements"></a> System requirements-

SNAQ-Vsoft CLI only supports Linux systems and uses the docker application. 

SNAQ-Vsoft CLI will verfiy both system requirements before proceeding.


```

$ bash snaq-vsoft.sh input=/home/input/fastq output=/home/output rg=/home/input/ref bc=/home/input/amplicon_basechange.txt norm=/home/input/normalization.txt outputSAM=0 offspringCutoff=0.01 mfs=0 RC=1 mapq=-1 qCutoff=0  gbc=1 outputIS=0 CC=300 IS=300 VERSION=v1

Linux system verified...

Docker application verified... 
``` 

## <a name="data"></a> Input data-

#### Sequencing files

Compressed fastq files for single or paired read should be provided depending of the analysis.

#### Reference genome:

SNAQ-Vsoft CLI uses the bwa aligner for the analysis which requires the reference genome (fasta format) and bwa indices. The reference genome is a single FASTA file containing human, viral and IS sequences.  The viral and IS are in the form of amplicons.  AccuGenomics will provide the viral and IS FASTA and the user will append this FASTA to their human FASTA (e.g., cat hg19.fasta ARTv31_NT_IS_CC_amplicons.fasta > hg19-ARTv31.fasta)

SNAQ-SEQ will verify if there are existing bwa indices made available that can be used for the analysis.

#### Base change file:

The basechange file maps the IS modified bases and is used to detect PCR template switching artifacts that create IS and NT recombinants.  This file is created using the -b option and the modified reference genome described above.
```
bash snaq-vsoft.sh -b /path/reference/genome/file.fasta
```
The base change file will be created in same directory as the reference genome.

#### Normalization File:

The normalization file provides inter IS abundance ratios used to improve the accuracy of amplicon abundance calculation.  This file contains two columns:

* IS amplicon names are in column 1, matching the IS sequence names in the FASTA file
* column 2 has the normalization factors

Note: the normalization file should not have column headers

## <a name="usage-options"></a> Usage-

For information about usage and options, run ```bash snaq-seq.sh -h```: 

All options are required to run the analysis.

```
$ bash snaq-vsoft.sh -h
 
     Snaq-Seq: QC for viral surveillance NGS testing.     

Usage: bash snaq-vsoft.sh input=/home/input/fastq/ output=/home/output rg=/home/input/ref/genome.fasta bc=/home/input/amplicon_basechange.txt norm=/home/input/normalization.txt outputSAM=0 offspringCutoff=0.01 mfs=0 RC=1 mapq=-1 qCutoff=0  gbc=1 outputIS=0 CC=300 IS=300 VERSION=v1
```

## Parameters:

Command line parameters will indicate path to input and output files, along with IS spike-in analysis parameters. There are a total of 16 options (depending on the input option, at least 1 filepath(s), at least 3 filenames, 9 integer values, 1 float value) to be provided in the following order on the command line: 

Note: There is also an additional option of generating the basechange when provided amplicon sequences through the -b parameter.

| Parameter           | Description
| ------------------- | -----------
| 1)  input           | File path to input FASTQ or directory path to FASTQ files (directory should only consist of FASTQ files)
| 2)  output          | Directory path to place analysis outputs.  Note: If you are rerunning the fastq and sam outputs will be overrided.
| 3)  rg              | File path of reference genome (FASTA format). The path directory must include bwa indices. The reference genome must also have:
|                     | - host/background, e.g., hg19
|                     | - IS amplicons (contig ID tagged with - SNAQ-IS)
|                     | - NT amplicons (contig ID with -SNAQ-NT)
|                     | - CC amplicons (contig ID tagged with -SNAQ-CC) 
| 4)  bc              | Filepath to basechange file.
| 5)  norm            | Filepath to IS amplicon normalization file.
| 6)  outputSAM       | For troubleshooting purposes, instruct script to output NT & IS SAM files for good reads (-pass.sam), IS x NT recombinant (-recombinant.sam) or unmapped (-mapq.sam) (0=False, 1=True).
| 7)  offspringCutoff       | Identify CC offspring that arise from sequencing errors of over duplicated complexity controls.  Offspring Cutoff is the fraction of maximum CC duplication, below which CC is concidered an NGS error and removed.  (float value, 0 to inactivate).
| 8)  mfs             | Minimum fragment size: minimum fragment length for good read (integer value, -1 to inactivate).
| 9)  RC              | Recombinant detection stringency: indicates how many recombinant bases allowed per read pair (integer value, must be >0).
| 10) mapq            | Mapping quality stringency used to eliminate amplicon overlap reads from SNAQ analysis (integer value, -1 to inactivate, 10 recommneded).
| 11) qCutoff         | Minimum Q score for good read for calling a base change position (integer value, 0 to inactivate).
| 12) gbc             | Number of base change positions in a fragment for it to be considered valid (integer value, must be >0).
| 13) outputIS        | Include IS reads in FASTQ output (0=False, 1=True).
| 14) CC              | Number of complexity control copies spiked into the sample (integer value).
| 15) IS              | Number of IS copies spiked into the sample. (integer values)
| 16) VERSION         | Docker container version to use for analysis (string).
| Additional          | 
| 1)  -b              | Filepath used when creating the base change file, see base change file description for more details.

SNAQ-Vsoft will verify if the options were provided appropriately before proceeding.

```
$ bash snaq-vsoft.sh input=/home/input/fastq output=/home/output rg=/home/input/ref/genome.fasta bc=/home/input/amplicon_basechange.txt norm=/home/input/normalization.txt outputSAM=0 offspringCutoff=0.01 mfs=0 RC=1 mapq=-1 qCutoff=0  gbc=1 outputIS=0 CC=300 IS=300 VERSION=v1

input=/home/input/fastq
output=/home/output
rg=/home/input/reference/genome.fasta
bc=/home/input/amplicon_basechange.txt
norm=/home/input/normalization.txt
outputSAM=0
offspringCutoff=0.01
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
A log file of the SNAQ-Vsoft CLI standard and error outputs may be obtained using:
```
snaq-vsoft.sh <parameters >> /path/to/log.txt 2>&1 
```

## <a name="docker"></a> Docker Container-

The SNAQ-Vsoft CLI pipeline is in a public container located on [DockerHub](https://hub.docker.com/r/accugenomics/snaq-seq/tags).

For more information on the software architecture and details of the SNAQ-Vsoft CLI pipeline, please refer to the folder snaq-vsoft_container-v1.
