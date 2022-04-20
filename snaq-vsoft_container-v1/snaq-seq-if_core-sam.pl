#!/usr/local/bin/perl
# author: "Thahmina A. Ali"
#
## Usage: perl /snaq-seq/snaq-seq-if_core-sam.pl $inputFILE_fasta $genome_fasta $outsam $ofs $mfs $rc $mpq $qc $gbc $outis $cc $is 
#
##      $inputFILE_fasta paired end fastq file names.
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
#       $is - Number of IS copies spiked into the sample. (integer values)
#
## Intended Use: The following script executes the core analysis using the inputs provided from user argument initially collected by the initFILE.sh script. It is divided into four launch steps that prepares the inputs, performs the alignment and counting, prepares the count results, and generates the unified table of the snaq-vsoft analysis.   
#
#Program flow: It is divided into four launch steps that prepares the inputs such as setting up the pipeline commands in parrallel mode, performs the alignment and counting in a subsequent fashion, gather read outputs in fastq output files, alignment files (sam)  for good reads, IS x NT recombinant, unmapped  and lastly performs the necessary calculations that produces final values resulted in a csv file (table).
#
## Example: perl /snaq-seq/snaq-seq-if_core-sam.pl CV21_47_002_12-5_w-IS_S146 hg19 0 0.01 0 1 1 0  1 0 300 300

use strict;
use warnings;
use Time::Piece;

system("clear");

my $time = localtime->strftime('%Y-%m-%d_%H:%M:%S');
my $inputFILE_R1= $ARGV[0];
my $inputFILE_R2= $ARGV[1];
my $inputFILE_fasta= $ARGV[2];
my $genome_fasta= $ARGV[3];
my $outputSAM= $ARGV[4];
my $offspringCutoff= $ARGV[5];
my $mfs= $ARGV[6];
my $RC= $ARGV[7];
my $mapq= $ARGV[8];
my $qCutoff= $ARGV[9];
my $gbc = $ARGV[10];
my $outputIS = $ARGV[11];
my $CC= $ARGV[12];
my $IS= $ARGV[13];


my $launch_1 = "mkdir /home/output/$time; mkdir /home/output/$time/$inputFILE_fasta; cd /home/ ; cp  /snaq-seq/snaq-seq-if_command-sam.sh /home/snaq-seq_launch-list.sh ; sed -i \'s/inputFILE_R1/$inputFILE_R1/g\' /home/snaq-seq_launch-list.sh; sed -i \'s/inputFILE_R2/$inputFILE_R2/g\' /home/snaq-seq_launch-list.sh;  sed -i \'s/FILE/$inputFILE_fasta/g\' /home/snaq-seq_launch-list.sh; sed -i \'s/TIME/$time/g\' /home/snaq-seq_launch-list.sh; sed -i \'s/GENOME/$genome_fasta/g\' /home/snaq-seq_launch-list.sh;  sed -i \'s/REPLACE/-v $offspringCutoff -v $mfs -v $RC -v $mapq -v $qCutoff -v $gbc -v $outputIS/g\' /home/snaq-seq_launch-list.sh; sed -i \'s/TIME/$time/g\' output_1.sh; sed -i \'s/,/;/g\' output_1.sh;  sed -i \'s/TIME/$time/g\' output_2.sh; cp /snaq-seq/snaq-vsoft_call.sh /home/$inputFILE_fasta.sh; sed -i \'s/TIME/$time/g\'  /home/$inputFILE_fasta.sh";


#my $launch_1 = "mkdir /home/output/$time; mkdir /home/output/$time/$inputFILE_fasta; cd /home/ ; cp  /snaq-seq/snaq-seq-if_command-sam.sh /home/snaq-seq_launch-list.sh ; sed -i \'s/inputFILE_R1/$inputFILE_R1/g\' /home/snaq-seq_launch-list.sh; sed -i \'s/inputFILE_R2/$inputFILE_R2/g\' /home/snaq-seq_launch-list.sh;  sed -i \'s/FILE/$inputFILE_fasta/g\' /home/snaq-seq_launch-list.sh; sed -i \'s/TIME/$time/g\' /home/snaq-seq_launch-list.sh; sed -i \'s/GENOME/$genome_fasta/g\' /home/snaq-seq_launch-list.sh;  sed -i \'s/REPLACE/-v $offspringCutoff -v $mfs -v $RC -v $mapq -v $qCutoff -v $gbc -v $outputIS/g\' /home/snaq-seq_launch-list.sh; sed -i \'s/TIME/$time/g\' output_1.sh; sed -i \'s/,/;/g\' output_1.sh;  sed -i \'s/TIME/$time/g\' output_2.sh; bash /home/snaq-seq_launch-list.sh"; 
system($launch_1);
wait;
print "******************************************************\n";
print "*                                                    *\n";
print "*        Initializing Snaq-seq...                    *\n";
print "*                            Launching...            *\n";
print "*                                                    *\n";
print "******************************************************\n";

print "\n";
print "Snaq-seq analysis in progress...\n";
print "\n";
wait;

print "\n";
my $launch_2 = "bash /home/$inputFILE_fasta.sh 2>> /home/error2 ";
system($launch_2);
print "\n";
print "Snaq-seq analysis generating results...\n";
print "\n";
wait;


my $launch_3 = "cd /home/output/$time/; cat -- '/home/output/$time/'*'/-PassCount.txt' > /home/output/$time/PassCount.txt; cat -- '/home/output/$time/'*'/-BadCount.txt' > /home/output/$time/BadCount.txt; cat -- '/home/output/$time/'*'/-BaseCount.txt' > /home/output/$time/BaseCount.txt;  cat -- '/home/output/$time/'*'/-mapqCount.txt' > /home/output/$time/mapqCount.txt; cat -- '/home/output/$time/'*'/-NMCount.txt' > /home/output/$time/NMCount.txt; cat -- '/home/output/$time/'*'/-offTargetCount.txt' > /home/output/$time/offTargetCount.txt; cat -- '/home/output/$time/'*'/-unmappedCount.txt' > /home/output/$time/unmappedCount.txt;  cat -- '/home/output/$time/'*'/-ComplexityCount.txt' > /home/output/$time/ComplexityCount.txt; cp /snaq-seq/snaq-seq-if_out-sam.sh /home/output/$time/; sed -i \'s/time/$time/g\' snaq-seq-if_out-sam.sh; sed -i \'s/sample/$inputFILE_fasta/g\' snaq-seq-if_out-sam.sh; bash snaq-seq-if_out-sam.sh; bash /home/output_1.sh;  bash /home/output_2.sh";
system($launch_3);
print "\n";
print "Snaq-seq analysis finalizing...\n";
print "\n";
wait;


my $launch_4 = "Rscript /snaq-seq/CombineThreads.R '/home/output/$time' '/home/data/output' '/home/data/normalization'  $offspringCutoff >> /home/error2" ;
system($launch_4);

print "\n";
