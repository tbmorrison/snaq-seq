#!/usr/local/bin/perl
# author: "Thahmina A. Ali"

## Usage: perl /snaq-seq/snaq-seq_core-sam.pl $inputFILE_fasta $genome_fasta $outsam $ofs $mfs $rc $mpq $qc $gbc $outis $cc $is 
#
##      $inputDIR folder to paired end fastq files.
##      $genome_fasta reference genome fasta file name.
##      $outsam -  For troubleshooting purposes, instruct script to output NT & IS SAM files for good reads (-pass.sam), IS x NT recombinant (-recombinant.sam) or unmapped (-mapq.sam) (0=False, 1=True).
##      $ofs - Identify CC offspring that arise from sequencing errors of over duplicated complexity controls. Offspring Cutoff is the fraction of maximum CC duplication, below which CC is concidered an NGS error and removed. (float value, 0 to inactivate).
##      $mfs - Minimum fragment size: minimum fragment length for good read (integer value, -1 to inactivate).
#       $rc - Recombinant detection stringency: indicates how many recombinant bases allowed per read pair (integer value, must be >0).
#       $mpq - Mapping quality stringency to be concidered a good read (integer value, -1 to inactivate).
#       $qc - Minimum Q score for good read for calling a base change position (integer value, -1 to inactivate).
#       $gbc - Number of base change positions in a fragment for it to be considered valid (integer value, must be >0).
#       $outis - Include IS reads in FASTQ output (0=False, 1=True).
#       $cc -   Number of complexity control copies spiked into the sample (integer value).
#       $is - Number of IS copies spiked into the sample. (integer values).
#
## Intended Use: The following script executes the core analysis using the inputs provided from user argument initially collected by the initFILE.sh script. It is divided into four launch steps that prepares the inputs, performs the alignment and counting, prepares the count results, and generates the unified table of the snaq-vsoft analysis.   
#
#Program flow: It is divided into four launch steps that prepares the inputs such as setting up the pipeline commands in parrallel mode, performs the alignment and counting in a subsequent fashion, gather read outputs in fastq output files, alignment files (sam)  for good reads, IS x NT recombinant, unmapped  and lastly performs the necessary calculations that produces final values resulted in a csv file (table).
#
#
## Example: perl /snaq-seq/snaq-seq_core-sam.pl /home/data/input/ hg19 0 0.01 0 1 1 0  1 0 300 300

use strict;
use warnings;
use Time::Piece;

system("clear");

my $time = localtime->strftime('%Y-%m-%d_%H:%M:%S');
my $inputDIR= $ARGV[0];
my $genome_fasta= $ARGV[1];
my $outputSAM= $ARGV[2];
my $offspringCutoff= $ARGV[3];
my $mfs= $ARGV[4];
my $RC= $ARGV[5];
my $mapq= $ARGV[6];
my $qCutoff= $ARGV[7];
my $gbc = $ARGV[8];
my $outputIS = $ARGV[9];
my $CC= $ARGV[10];
my $IS= $ARGV[11];

my $launch_1 = "mkdir /home/output/$time; cd /home/ ; bash /snaq-seq/make_dir.sh; bash /snaq-seq/snaq-seq_command-sam.sh; bash /snaq-seq/snaq-seq_launch.sh; sed -i \'s/TIME/$time/g\'  make_dir_list.sh; sed -i \'s/TIME/$time/g\'  snaq-seq_launch_list.sh; sed -i \'s/TIME/$time/g\' snaq-seq_runs_list.sh;  sed -i \'s/GENOME/$genome_fasta/g\' snaq-seq_runs_list.sh;  sed -i \'s/REPLACE/-v $offspringCutoff -v $mfs -v $RC -v $mapq -v $qCutoff -v $gbc -v $outputIS/g\' snaq-seq_runs_list.sh; sed -i \'s/TIME/$time/g\' output_1.sh; sed -i \'s/TIME/$time/g\' output_2.sh; bash snaq-seq_runs_list.sh";
system($launch_1);
wait;
print "******************************************************\n";
print "*                                                    *\n";
print "*        Initializing Snaq-seq...                    *\n";
print "*                            Launching...            *\n";
print "*                                                    *\n";
print "******************************************************\n";

print "\n";
my $launch_2 = "bash /home/make_dir_list.sh";
system($launch_2);
print "\n";
print "Snaq-seq analysis in progress...\n";
print "\n";
wait;

print "\n";
my $launch_3 = "bash /home/snaq-seq_launch_list.sh  ";
system($launch_3);
print "\n";
print "\n";
print "Snaq-seq analysis generating results...\n";
print "\n";
wait;

my $launch_4 = "cd /home/output/$time/; cat -- '/home/output/$time/'*'/-PassCount.txt' > /home/output/$time/PassCount.txt; cat -- '/home/output/$time/'*'/-BadCount.txt' > /home/output/$time/BadCount.txt; cat -- '/home/output/$time/'*'/-BaseCount.txt' > /home/output/$time/BaseCount.txt;  cat -- '/home/output/$time/'*'/-mapqCount.txt' > /home/output/$time/mapqCount.txt; cat -- '/home/output/$time/'*'/-NMCount.txt' > /home/output/$time/NMCount.txt; cat -- '/home/output/$time/'*'/-offTargetCount.txt' > /home/output/$time/offTargetCount.txt; cat -- '/home/output/$time/'*'/-unmappedCount.txt' > /home/output/$time/unmappedCount.txt;  cat -- '/home/output/$time/'*'/-ComplexityCount.txt' > /home/output/$time/ComplexityCount.txt; bash /home/output_1.sh;  bash /home/output_2.sh";
system($launch_4);
print "\n";
print "Snaq-seq analysis finalizing...\n";
print "\n";
wait;

my $launch_5 = "cd /home/output/$time/; bash /snaq-seq/snaq-seq_out-sam.sh; sed -i \'s/time/$time/g\' snaq-seq_out-sam_list.sh;bash snaq-seq_out-sam_list.sh";
system($launch_5);
wait;


my $launch_6 = "Rscript /snaq-seq/CombineThreads.R '/home/output/$time'  '/home/data/output' '/home/data/normalization' $offspringCutoff >> /home/error2" ;
system($launch_6);

print "\n";
