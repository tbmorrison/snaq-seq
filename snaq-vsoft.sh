#!/usr/bin/env bash

#script0c <path/to/file/list> <single=1,pair=2> <path/to/SNAQ/output/csv>
#This script feeds fastq files, whose full path is pointed to in text file,
#into indicated SNAQ-SEQ container
#
#the csv path will also be the directory where output fastq are put.
#NOTE:script assumes reference genome + basechange file + normalizer file are in same directory
#   output fastq & bams, scratch, output SNAQ CSV are in output directory

#rg="/NGS/REFS/SARS-CoV-2/ARCV30-NT-IS-xCC-amplicon.fasta"
#nf="/NGS/REFS/SARS-CoV-2/ARCV30_normalizer.txt"
#bc="/NGS/REFS/SARS-CoV-2/ARCV30_basechange.txt"
if [ "$#" -ne 3 ];then
	echo "snaq-vsoft.sh <path/to/file/list> <single=1,pair=2> <path/to/SNAQ/output/csv>"
	exit 1
fi

# Verify Docker installation.
res=$(docker ps 2>&1)
res_str=$(echo ${res::+10})
if [[ ! "$1" == "-b" ]]; then
	if [ "$res_str" != "CONTAINER" ]; then
		docker=false
		printf "** [ERROR] - Docker is not installed...\n\n"
	else
		docker=true
		printf "Docker application verified... \n"
	fi
fi

rg="/NGS/REFS/sarscov2-v41/hg19-arc41.fasta"
nf="/NGS/REFS/sarscov2-v41/ARCV41-normalizer220629.txt"
bc="/NGS/REFS/sarscov2-v41/ARCV41-basechange_file.txt" #removed extra CC lines

po="$(dirname ${3})"
of="${3}"
sd="${po}/scratch"
cc=2000 #Complexity caputre input copies
is=2000 #Internal standard input copies
log="${po}/log.txt"
tag_sel="v1.1" #version of SNAQ vsoft

# Get array of tags for accugenomics/snaq-seq
tags=`wget -q https://registry.hub.docker.com/v1/repositories/accugenomics/snaq-seq/tags -O - | sed -e 's/[][]//g' -e 's/[{}]//g' -e 's/"//g' -e 's/layer: //g' -e 's/name: //g'`
tags_arr=($(echo "$tags" | tr ',' '\n'))
if [[ ! ${tags_arr[*]} =~ $tag_sel ]]; then
		printf "** [ERROR] - Selected VERSION not found in Docker Hub. Available versions are: **\n"
    		for i in "${tags_arr[@]}"
    		do
        			echo "$i"
    		done
		exit 1
else
		pull_cmd="docker pull accugenomics/snaq-seq:$tag_sel"
		eval $pull_cmd
fi


input=${1}
index=0
while read -r line;do

if [[ ! $line =~ ^# ]];then
    temp1[$index]="${line}"
	if [[ $2 == "0" || $2 == "2" ]];then
		read -r line
		temp2[$index]="${line}"  
	fi
    index=$((index+1))
fi
done < "${input}"

#to use -ti docker option, don't run docker in a file input loop.
#Thus, fasta paths first collected in an array, then array is looped.
for i in ${!temp1[@]};do
docker run \
    -u "$(id -u)":"$(id -g)" \
    --rm \
    -e op="${po}" `#output directory full path` \
    -e rg="${rg}" `#reference genome fasta full path` \
    -e bc="${bc}" `#full path to base change file` \
    -e sd="${sd}" `#full path to scratch directory` \
    -e of="${of}" `#full path to SNAQ analysis output file` \
    -e th=50 `#number of threads for SNAQ analysis multi thread` \
    -e bo=1 `#Output SNAQ sorted bam files (pass, CC, recombo, mapq)` \
    -e cco=0.01 `#complexity capture offspring filter` \
    -e mf=0 `#minimum fragment size for PASS` \
    -e rc=1 `#PASS fragment must have < rc recombinants detected` \
    -e mq=10 `#minimum mapq score for PASS` \
    -e mbc=1 `#minimum number of base change positions per fragment` \
    -e oi=0 `#oi=1, output fastq containing IS along with NT` \
    -e qs=0 `#ignore basechange position if qscore <qs` \
    -e nf="${nf}" `#full path to normalizer file` \
    -e is=$is `#IS copies added to sample` \
    -e cc=$cc `#CC copies added to sample` \
    -e f1="${temp1[$i]}" `#full path to fastq R1` \
    -e f2="${temp2[$i]}" `#full path to fastq R2` \
    -v "${po}":"${po}" `#give docker path to output directory` \
    -v $(dirname "${rg}"):$(dirname "${rg}") `#allow docker access to reference genome directory` \
    -v $(dirname "${temp1}"):$(dirname "${temp1}") `#Allow docker access to fastq file directory` \
    -ti "accugenomics/snaq-seq:${tag_sel}" /snaq-seq/snaq >> "${log}"
done
