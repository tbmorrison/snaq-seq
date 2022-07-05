# SNAQ-Vsoft CLI QC tool for viral surveillance NGS testing. 

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

The snaq-vsoft scripts are run in this docker.  See docker documentation for more snaq-vsoft details.
```
https://hub.docker.com/repository/docker/accugenomics/snaq-seq

```
## <a name="Repo-contents"></a> Repo Contents-
This repo contains example scripts, as well as the working snaq analysis scripts.

Script0c : example bash script on how to feed fastq at a time to snaq-vsoft
script0d : example bash script on how to create base change file used by the snaq analysis script
docker-scripts: contains working copies of the snaq scripts found in the docker container
fastq_lane_merging.sh: merges multi-lane sample fastq into a single lane for snaq-vsoft analysis
LICENSE: MIT license that applies to these scripts

