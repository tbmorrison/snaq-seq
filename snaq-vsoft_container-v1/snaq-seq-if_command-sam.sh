# author: "Thahmina A. Ali"
# Usage: Simulates the commands for the core analysis that multithreads the run process (bwa) and memory for the counting algorithm (awk) amd generation of filtered reads and aligned reads (sam) for a single sample. 
# Please refer to README.md for program flow and further information.

ls /home/data/input/FILE_R1_* | awk 'BEGIN {FS="_R1|/"};  {print "echo \"cd /home/output/TIME/FILE/ ;  echo Analysis FILE...run start time: \\$(date +%T); bwa mem -v 1 -R \\\"@RG\\\\tID:FILE\\\\tSM:FILE\\\\tLB:NA\\\\tPL:SNAQ\\\" -t 8 /home/data/ref/GENOME "$1"/"$2"/"$3"/"$4"/FILE_R1"$6" "$1"/"$2"/"$3"/"$4"/FILE_R2"$6" | parallel -k -q --block 10M --pipe  awk -f /snaq-seq/remRecombo.awk -v sampleName=FILE -v outputSAM=/home/data/output REPLACE /home/data/basechange/amplicon_basechange.txt - | parallel -k -q --block 10M --pipe awk -f /snaq-seq/makeFastq.awk -v file1=/home/data/output/FILE_R1_001.fastq -v file2=/home/data/output/FILE_R2_001.fastq - ; echo Analysis FILE...run end time: \\$(date +%T) \"  > /home/FILE_snaq-seq.sh  "}' > snaq-seq_runs_list.sh


