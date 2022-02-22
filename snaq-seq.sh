#!/usr/bin/env bash
# Author: "Thahmina A. Ali"


#Display Help.
Help()
{
   # Display Help
   echo " "
   echo "     Snaq-Seq: QC for viral surveillance NGS testing.     "
   echo
   echo "Usage: bash snaq-seq.sh input=/home/input/fastq output=/home/output rg=/home/input/ref bc=/home/input/amplicon_basechange.txt norm=/home/input/normalization.txt outputSAM=0 ofsCutoff=0.01 mfs=0 RC=1 mapq=-1 qCutoff=0  gbc=1 outputIS=0 CC=300 IS=300"
   echo
   echo "Options:"
   echo
   echo "There are a total of 15 options (3 filepaths, 2 filenames, 10 integer values) to be provided in the following order on the command line:"
   echo " "
   echo "1)  input=                  Location folder path to fastq files (folder should only consist of fastq input)."
   echo "2)  output=                 Location folder path to place analysis outputs."
   echo "3)  rg=       	            Location folder path of reference genome (fasta format) and bwa indices."
   echo "4)  bc=                     Location file path of basechange file."
   echo "5)  norm=                   Location file path of IS amplicon adjustment (normalization) file (tab seperated format)."
   echo "6)  outputSAM=              Alignment output in SAM format (0=False, 1=True) (integer value)."
   echo "7)  ofsCutoff=              offspring Cutoff (integer value)."
   echo "8)  mfs=                    Minimum fragment size (integer value)."
   echo "9)  RC=                     RC (integer value)."
   echo "10) mapq=                   Mapping quality (integer value)."
   echo "11) qCutoff=                QC cutoff (integer value)."
   echo "12) gbc=                    basechange (integer value)."
   echo "13) outputIS=               Include IS sequences in fastq output (integer value)."
   echo "14) CC=                     Complexity control copies (integer value)."
   echo "15) IS=                     Internal standards (integer value)."
   echo
}
while getopts ":h" option; do
   case $option in
      h) # display Help
         Help
         exit;;
   esac
done

# Handle no options.
NO_ARGS=0
if [ $# -eq "$NO_ARGS" ]; then
    echo "*** No options were provided. Please run 'snaq-seq.sh -h' for more information. ***"
    exit 1
fi

# Verify Linux environment.
if [ "$(expr substr $(uname -s) 1 5)" = "Linux" ]; then
    user_os="Linux"
        printf "\n\nLinux system verified...\n\n"
else
        printf "** [ERROR] - Snaq-seq only supports Linux systems.\n\t Please run snaq-seq on a Linux environment. \n"
        exit 1
fi

# Verify Docker installation.
res=$(docker ps 2>&1)
res_str=$(echo ${res::+10})
if [ "$res_str" != "CONTAINER" ]; then
	docker=false
		printf "** [ERROR] - Docker is not installed...\n\n"
		for app in 'wget' 'unzip' 'python' 'lsof'; do
                        command -v $app >/dev/null 2>&1 || { echo >&2 "** Installing $app.."; apt-get update; apt-get install -y $app > /dev/null 2>&1; }
                done
                command -v docker >/dev/null 2>&1 || { echo >&2 "** Installing Docker.."; wget -qO- https://get.docker.com/ | sh > /dev/null 2>&1; }
else
	docker=true
	   printf "Docker application verified... \n"
fi



# Gather options and verify user options
echo -e "\nGathering options...Verify user options... \n";
echo "$1";
echo "$2";
echo "$3";
echo "$4";
echo "$5";
echo "$6";
echo "$7";
echo "$8";
echo "$9";
echo "${10}";
echo "${11}";
echo "${12}";
echo "${13}";
echo "${14}";
echo -e "${15} \n";

input=$(echo ${1} |sed 's/.*=//g')
output=$(echo ${2} |sed 's/.*=//g')
ref=$(echo ${3} |sed 's/.*=//g')
bc_amp=$(echo ${4} |sed 's/.*=//g')
norm_amp=$(echo ${5} |sed 's/.*=//g')


# If options verified from user.
docker run -e outsam="$6" -e ofs="$7" -e mfs="$8" -e rc="$9" -e mpq="${10}" -e qc="${11}"  -e gbc="${12}" -e outis=${13}   -e cc="${14}" -e is=${15}  -v $input:/home/data/input  -v $output:/home/data/output  -v $ref:/home/data/ref  -v $bc_amp:/home/data/basechange/bc_amplicon.txt -v $norm_amp:/home/data/normalization/amplicon_adjustment.txt -ti accugenomics/snaq-seq:v1 




