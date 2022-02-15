# snaq-seq
Command Line Interface, output native sequences, SNAQ QC


For information about usage and options, run ```bash snaq-seq.sh -h```: 

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
9)  QC:                                 QC (integer value).
10) CC:                                 CC (integer value).
11) IS:                                 IS (integer value).
```
