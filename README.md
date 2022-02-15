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

## <a name="data"></a> Input data-

#### Reference genome:

#### Reference amplicon:

#### Adjustment amplicon:


## <a name="usage-options"></a> Usage-

For information about usage and options, run ```bash snaq-seq.sh -h```: 

All options are required to run the analysis.

```

$ bash snaq-seq.sh -h 

     Snaq-Seq: QC for viral surveillance NGS testing.     

Usage: bash snaq-seq.sh /home/input/fastq /home/output /home/input/reference_genome.fasta /home/input/reference_amplicon.fasta /home/input/amplicon_adjustment.txt 60 1 1 0 300 300

Options:

There are a total of 11 options (2 filepaths, 3 filenames, 6 integer values) to be provided in the following order on the command line:
 
1)  Fastq path:                  	Location path of the fastq files (folder should only consist of fastq input).
2)  Output path:                        Location path of folder to place analysis outputs.
3)  Reference genome file:       	Location file path of reference genome (fasta format).
4)  Reference amplicon fasta file:      Location file path of reference amplicon (fasta format). This is to create the basechange file required for QC.
5)  IS amplicon adjustment file:        Location file path of IS amplicon adjustment file (tab seperated format).
6)  Minimum fragment size:              Minimum fragment size (integer value).
7)  RC:                                 RC (integer value).
8)  Mapping quality                     Mapping quality (integer value).
9)  QC:                                 QC cutoff (integer value).
10) CC:                                 Complexity control copies (integer value).
11) IS:                                 Internal standards (integer value).
```

Snaq-seq will ask to verify if the options were provided appropriately before proceeding.

```

$ bash snaq-seq.sh /home/input/fastq /home/output /home/input/reference_genome.fasta /home/input/reference_amplicon.fasta /home/input/amplicon_adjustment.txt 60 1 1 0 300 300

... 

Gathering options... 
Fastq path: /home/input/fastq
Output path: /home/output
Reference genome file: /home/input/reference_genome.fasta
Reference amplicon file: /home/input/reference_amplicon.fasta
IS amplicon file: /home/input/amplicon_adjustment.txt
Minimum fragment size: 60
RC: 1
Mapping quality: 1
QC: 0
CC: 300
IS: 300 


  \* Please review the options provided above. 
 All of the options are required for the analysis, are they specified and indicated in the correct order? 
  Type [Y/N]: 
```
