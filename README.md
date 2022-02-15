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

If docker is not installed, the pre-alpha version will attempt to set up docker. The installation may be subjected to requiring admin priveleges. 

Snaq-seq will verfiy both system requirements before proceeding.

```

$ bash snaq-seq.sh /home/input/fastq /home/output /home/input/reference_genome.fasta /home/input/reference_amplicon.fasta /home/input/amplicon_adjustment.txt 60 1 1 0 300 300


Linux system verified...

Docker application verified... 
``` 

## <a name="data"></a> Input data-

#### Reference genome:

Snaq-seq uses the bwa aligner for the analysis which requires the reference genome (fasta format) and bwa indices. 

Snaq-seq will verify if there are existing bwa indices made available that can be used for the analysis.

```

$ bash snaq-seq.sh /home/input/fastq /home/output /home/input/reference_genome.fasta /home/input/reference_amplicon.fasta /home/input/amplicon_adjustment.txt 60 1 1 0 300 300

...


* Does your reference genome data include bwa indices? 
If yes, please make sure they are located in the same folder where the reference genome is, the file path will be asked for. 
If no, the analysis will build the bwa indices on the fly. 
  Type [Y/N]:
```

If the answer is Y (yes), you will be asked to provide the filepath location in which both the bwa indices and references are located in the same folder.

* Note: If Snaq-seq is unable to detect any bwa indices it will proceed with generating indices on the fly to be used for the analysis.


```

$ bash snaq-seq.sh /home/input/fastq /home/output /home/input/reference_genome.fasta /home/input/reference_amplicon.fasta /home/input/amplicon_adjustment.txt 60 1 1 0 300 300

...


Type [Y/N]: Y
* Please provide the file path (no file names) of the indices location (reference genome must be located in same path): /home/input/ref

* Snaq-seq is preparing to launch... 
```

If the answer is N (no), Snaq-seq will proceed to generate bwa on the fly and verify if the indices should be saved for future analysis.

```

$ bash snaq-seq.sh /home/input/fastq /home/output /home/input/reference_genome.fasta /home/input/reference_amplicon.fasta /home/input/amplicon_adjustment.txt 60 1 1 0 300 300

...


Type [Y/N]: N

* Do you want to keep the bwa indices that will be generated for future analysis?:
 Type [Y/N]: Y

* Snaq-seq is preparing to launch... 
```

#### Reference amplicon:

The reference amplicon is required to be provided in fasta format. This is to be used to generate the basechange data for the analysis.

#### Adjustment amplicon:

The adjustment amplicon is required to be provided in tab seperated format used to generate result values in the output.

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


  * Please review the options provided above. 
 All of the options are required for the analysis, are they specified and indicated in the correct order? 
  Type [Y/N]: 
```
