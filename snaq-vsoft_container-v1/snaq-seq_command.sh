# author: "Thahmina A. Ali"
# Usage: Simulates the commands for the core analysis that multithreads the run process (bwa) and memory for the counting algorithm (awk) amd generation of filtered reads. 
# Please refer to README.md for program flow and further information.


ls /home/data/input/*_R1_* | awk 'BEGIN {FS="_R1|/"};  {print "echo \"cd /home/output/TIME/"$5"/ ;  echo Analysis "$5"...run start time: \\$(date +%T); bwa mem -v 1 -R \\\"@RG\\\\tID:"$5"\\\\tSM:"$5"\\\\tLB:NA\\\\tPL:SNAQ\\\" -t 8 /home/data/ref/GENOME "$1"/"$2"/"$3"/"$4"/"$5"_R1"$6" "$1"/"$2"/"$3"/"$4"/"$5"_R2"$6" | parallel -k -q --block 10M --pipe  awk -f /snaq-seq/remRecombo.awk -v sampleName="$5" -v outputSAM=0 REPLACE /home/data/basechange/amplicon_basechange.txt - | awk -f /snaq-seq/makeFastq.awk -v file1=/home/data/output/"$5"_R1_001.fastq -v file2=/home/data/output/"$5"_R2_001.fastq - ; echo Analysis "$5"...run end time: \\$(date +%T) \"  > /home/"$5"_snaq-seq.sh  "}' > snaq-seq_runs_list.sh


