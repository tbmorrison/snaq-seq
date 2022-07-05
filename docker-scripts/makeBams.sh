#!/bin/bash -e
#make bam files from all fastq in directory
#makeBams.sh <path/file/with/wildcard> <extension>  
#extension examples .fastq or .fastq.gz
#example bash /NGS/USAF/sbir/makeBams.sh /NGS/USAF/220307/newfastq-cli/*_ME_L001_R1_001 .fastq
pre="${1}"
ext="${2}"
#rg="/NGS/USAF/REFS/hg19-MID121.fasta"
rg="/NGS/REFS/SARS-CoV-2/MN908947.3.fa"

rn="$(basename ${rg})"
rn=${rn%.*}
arr=(${pre}${ext})

for i in "${arr[@]}";do
	bwa mem -t 42 "${rg}" "${i}" "${i/_R1/_R2}" | samtools sort -@10 -o "${i/${ext}/-${rn}}.bam" -
	samtools index "${i/${ext}/-${rn}}.bam"
done
