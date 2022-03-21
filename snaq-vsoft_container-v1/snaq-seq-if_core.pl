#!/usr/local/bin/perl
# author: "Thahmina A. Ali"
use strict;
use warnings;
use Time::Piece;

system("clear");

my $time = localtime->strftime('%Y-%m-%d_%H:%M:%S');
my $inputFILE_fasta= $ARGV[0];
my $genome_fasta= $ARGV[1];
my $outputSAM= $ARGV[2];
my $ofsCutoff= $ARGV[3];
my $msf= $ARGV[4];
my $RC= $ARGV[5];
my $mapq= $ARGV[6];
my $qCutoff= $ARGV[7];
my $gbc = $ARGV[8];
my $outputIS = $ARGV[9];
my $CC= $ARGV[10];
my $IS= $ARGV[11];



my $launch_1 = "mkdir /home/output/$time; mkdir /home/output/$time/$inputFILE_fasta; cd /home/ ; cp  /snaq-seq/snaq-seq-if_command.sh /home/; sed -i \'s/FILE/$inputFILE_fasta/g\' /home/snaq-seq-if_command.sh; bash /home/snaq-seq-if_command.sh; bash /snaq-seq/snaq-seq_launch.sh; sed -i \'s/TIME/$time/g\'  snaq-seq_launch_list.sh; sed -i \'s/TIME/$time/g\' snaq-seq_runs_list.sh;  sed -i \'s/GENOME/$genome_fasta/g\' snaq-seq_runs_list.sh;  sed -i \'s/REPLACE/-v $ofsCutoff -v $msf -v $RC -v $mapq -v $qCutoff -v $gbc -v $outputIS/g\' snaq-seq_runs_list.sh; sed -i \'s/TIME/$time/g\' output_1.sh; sed -i \'s/TIME/$time/g\' output_2.sh; sed -i \'s/FILE/$inputFILE_fasta/g\' output_1.sh; sed -i \'s/,/;/g\' output_1.sh; sed -i \'s/FILE/$inputFILE_fasta/g\' output_2.sh; bash snaq-seq_runs_list.sh"; 
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
my $launch_2 = "bash /home/snaq-seq_launch_list.sh  ";
system($launch_2);
print "\n";
print "Snaq-seq analysis generating results...\n";
print "\n";
wait;

my $launch_4 = "cd /home/output/$time/; cat /home/output/$time/*/PassCount.txt > /home/output/$time/PassCount.txt; cat /home/output/$time/*/BadCount.txt > /home/output/$time/BadCount.txt; cat /home/output/$time/*/BaseCount.txt > /home/output/$time/BaseCount.txt;  cat /home/output/$time/*/mapqCount.txt > /home/output/$time/mapqCount.txt; cat /home/output/$time/*/NMCount.txt > /home/output/$time/NMCount.txt; cat /home/output/$time/*/offTargetCount.txt > /home/output/$time/offTargetCount.txt; cat /home/output/$time/*/unmappedCount.txt > /home/output/$time/unmappedCount.txt;  cat /home/output/$time/*/ComplexityCount.txt > /home/output/$time/ComplexityCount.txt; bash /home/output_1.sh;  bash /home/output_2.sh";
system($launch_4);
print "\n";
print "Snaq-seq analysis finalizing...\n";
print "\n";
wait;

my $launch_5 = "Rscript /snaq-seq/CombineThreads.R '/home/output/$time' '/home/data/output' '/home/data/normalization' >> /home/error2" ;
#cp /home/output/$time/SNAQ-SEQ*  /home/data/output/$time/";
system($launch_5);


print "\n";






