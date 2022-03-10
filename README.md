# Snaq-Seq: command line QC tool for viral surveillance NGS testing. 

Table of Contents
-----------------
- [Objective](#objective)
- [System requirements](#requirements)
- [Input data](#data)
  1. [Reference genome](#reference-genome)
  2. [Reference amplicon](#reference-amplicon)
  3. [Adjustment amplicon](#adjustment-amplicon)
- [Usage](#usage-options)

## <a name="objective"></a> Objective-

## <a name="requirements"></a> System requirements-

Snaq-seq only supports Linux systems and uses the docker application. 

If docker is not installed, the beta version will attempt to set up docker that will require sudo (admin) priveleges. 

Snaq-seq will verfiy both system requirements before proceeding.

```

$ bash snaq-seq.sh input=/home/input/fastq output=/home/output rg=/home/input/ref bc=/home/input/amplicon_basechange.txt norm=/home/input/normalization.txt outputSAM=0 ofsCutoff=0.01 mfs=0 RC=1 mapq=-1 qCutoff=0  gbc=1 outputIS=0 CC=300 IS=300

Linux system verified...

Docker application verified... 
``` 

## <a name="data"></a> Input data-

#### Reference genome:

Snaq-seq uses the bwa aligner for the analysis which requires the reference genome (fasta format) and bwa indices. 

Snaq-seq will verify if there are existing bwa indices made available that can be used for the analysis.


* Note: If Snaq-seq is unable to detect any bwa indices in the filepath provided, it will proceed with generating indices on the fly to be used for the analysis (the generated indices won't be saved).


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

Options:

There are a total of 15 options (3 filepaths, 2 filenames, 10 integer values) to be provided in the following order on the command line:
 
1)  input=                  Location folder path to fastq files (folder should only consist of fastq input).
2)  output=                 Location folder path to place analysis outputs.
3)  rg=       	            Location file path of reference genome (fasta format). The path must include bwa indices.
4)  bc=                     Location file path of basechange file.
5)  norm=                   Location file path of IS amplicon adjustment (normalization) file (tab seperated format).
6)  outputSAM=              Alignment output in SAM format (0=False, 1=True) (integer value).
7)  ofsCutoff=              offspring Cutoff (float value).
8)  mfs=                    Minimum fragment size (integer value).
9)  RC=                     RC (integer value).
10) mapq=                   Mapping quality (integer value).
11) qCutoff=                QC cutoff (integer value).
12) gbc=                    basechange (integer value).
13) outputIS=               Include IS sequences in fastq output (integer value).
14) CC=                     Complexity control copies (integer value).
15) IS=                     Internal standards (integer value).
15) IS=                     Internal standards (integer value).
16) VERSION=                Docker container version (string value).
```

Snaq-seq will  verify if the options were provided appropriately before proceeding.

```
$ bash snaq-seq.sh input=/home/input/fastq output=/home/output rg=/home/input/ref/genome.fasta bc=/home/input/amplicon_basechange.txt norm=/home/input/normalization.txt outputSAM=0 ofsCutoff=0.01 mfs=0 RC=1 mapq=-1 qCutoff=0  gbc=1 outputIS=0 CC=300 IS=300 VERSION=v1

... 

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
