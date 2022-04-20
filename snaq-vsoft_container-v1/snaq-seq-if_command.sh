# author: "Thahmina A. Ali"
# Usage: Simulates the commands for the core analysis that multithreads the run process (bwa) and memory for the counting algorithm (awk) amd generation of filtered reads for a single sample. 
# Please refer to README.md for program flow and further information.


ref=/home/data/ref/GENOME 
t="8"
v="1"
cores=$(lscpu | grep "CPU(s):" | head -1 | sed 's/\s//g' | cut -d":" -f2)
R1="$1"
R2="$2"

export ref
export t
export v
export cores
export R1
export R2

snaq_vsoft() {


bwa mem -v $v -R "@RG\tID:FILE\tSM:FILE\tLB:NA\tPL:SNAQ" -t $t /home/data/ref/GENOME /home/data/input/inputFILE_R1 /home/data/input/inputFILE_R2 | parallel --pipe -k  awk -f /snaq-seq/remRecombo.awk -v sampleName=FILE -v samOutput=0 REPLACE /home/data/basechange/amplicon_basechange.txt - |  awk -f /snaq-seq/makeFastq.awk -v file1=/home/output/TIME/FILE/FILE_R1_001.fastq -v file2=/home/output/TIME/FILE/FILE_R2_001.fastq -  ; bgzip --threads $cores < /home/output/TIME/FILE/FILE_R1_001.fastq > /home/output/TIME/FILE/FILE_R1_001.fastq.gz; bgzip --threads $cores < /home/output/TIME/FILE/FILE_R2_001.fastq > /home/output/TIME/FILE/FILE_R2_001.fastq.gz;  mv /home/output/TIME/FILE/FILE_R*_001.fastq.gz  /home/data/output/


}

export -f snaq_vsoft

parallel -j $t --verbose --joblog jobRuntime.log -k snaq_vsoft ::: /home/data/input/inputFILE_R1 ::: /home/data/input/inputFILE_R2 ; 

cut -f4 jobRuntime.log | tail -1 | awk '{print "Core analysis (alignment, counting etc.)...job run time: " $1}'
