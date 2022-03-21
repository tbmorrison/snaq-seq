<h1>SNAQ-Vsoft CLI pipeline for viral surveillance NGS testing.</h1>

<h2>Description</h2>

This container image contains all necessary executables and dependencies for the SNAQ-Vsoft Command Line Interface (CLI) for viral surveillance testing by next-generation sequencing (NGS). Please refer to the complete description of SNAQ-VSoft CLI system requirements, inputs, and parameters at the [SNAQ-Vsoft CLI github page](https://github.com/tbmorrison/snaq-vsoft).


<h2>Versioning/Tags</h3>
All images are released with the following tag structure:
`<major release>.<changed software package>`

Release history:

* v1.0 - March 22, 2022 - Core SNAQ-VSoft CLI functionality for paired-end reads, one sample per fastq file pair.


<h3>Pipeline contents/workflow</h3>

Scripts indcluded in the pipeline and the control flow are briefly described below; please also refer to the included flowchart.

1) Pipeline initiation with selected parameters
    init-inputDIR.sh - if input is a directory of .fastq files.
    init-inputFILE.sh - if input is a single .fastq file.

2) Pipeline main
    If InputDIR:
	Initiate core pipeline analyses scripts; bwa SAM output options:
        a) snaq-seq_core-sam.pl - bwa alignment SAM file output
        b) snaq-seq_core.pl - no SAM file output
    If InputFILE:
        a) snaq-seq-if_core-sam.pl - bwa alignment SAM file output
        b) snaq-seq-=if_core.pl - no SAM file output

3) Pipeline setup and parallel core alignment analysis exectuion:
    make_dir.sh - create necessary file structure
    snaq-seq-if_command-sam.sh - alignment commands for input file, with SAM output
    snaq-seq-if_command.sh - alignment commands for input file, no SAM output
    snaq-seq-if_launch.sh - launch alignments and parallel processing for input file
    snaq-seq-command-sam.sh - alignment commands for input directory, with SAM output
    snaq-seq-command.sh - alignment commands for input directory, no SAM output
    snaq-seq-launch.sh - launch alignments and parallel processing for input director

4) Counting algorithm
    remRecombo.awk - process count streams by read type (viral sequence or internal standards)

5) Output generation
    makeFastq.awk - prepare and output processed .fastq file(s)
    CombineThreads.R - aggregate read types, calculate summary statistics, output to .csv

<img src="https://github.com/tbmorrison/snaq-seq/tree/main/snaq-vsoft_container-v1/snaq_vsoft_flow.png" align="center"  />
