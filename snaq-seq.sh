#!/usr/bin/env bash
# Author: "Thahmina A. Ali"


#Display Help.
Help()
{
   # Display Help
   echo " "
   echo "     Snaq-Seq: QC for viral surveillance NGS testing.     "
   echo
   echo "Usage: bash snaq-seq.sh /home/input/fastq /home/output /home/input/reference_genome.fasta /home/input/reference_amplicon.fasta /home/input/amplicon_adjustment.txt 60 1 1 0 300 300"
   echo
   echo "Options:"
   echo
   echo "There are a total of 11 options (2 filepaths, 3 filenames, 6 integer values) to be provided in the following order on the command line:"
   echo " "
   echo "1)  Fastq path:                  	Location path of the fastq files (folder should only consist of fastq input)."
   echo "2)  Output path:                        Location path of folder to place analysis outputs."
   echo "3)  Reference genome file:       	Location file path of reference genome (fasta format)."
   echo "4)  Reference amplicon file:      Location file path of reference amplicon (fasta format). This is to create the basechange file required for QC."
   echo "5)  IS amplicon adjustment file:        Location file path of IS amplicon adjustment file (tab seperated format)."
   echo "6)  Minimum fragment size:              Minimum fragment size (integer value)."
   echo "7)  RC:                                 RC (integer value)."
   echo "8)  Mapping quality                     Mapping quality (integer value)."
   echo "9)  QC:                                 QC cutoff (integer value)."
   echo "10) CC:                                 Complexity control copies (integer value)."
   echo "11) IS:                                 Internal standards (integer value)."
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
        printf "** [ERROR] - This script only supports Linux systems.\n\t Please run this script on a Linux environment. \n"
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



# Gather options.
echo -e "\nGathering options... \n";
echo "Fastq path: $1";
echo "Output path: $2";
echo "Reference genome file: $3";
echo "Reference amplicon file: $4";
echo "IS amplicon file: $5";
echo "Minimum fragment size: $6";
echo "RC: $7";
echo "Mapping quality: $8";
echo "QC: $9";
echo "CC: ${10}";
echo -e "IS: ${11} \n";


# Verify user options.
while true; do
        printf "\n * Please review the options provided above. \n All of the options are required for the analysis, are they specified and indicated in the correct order? \n "
        read -r -p " Type [Y/N]: " yn
        yn=$(echo $(echo -e "$yn" | tr -d '[:space:]'))
        if [ "$yn" = "Y" ] || [ "$yn" = "y" ]; then
                break
	elif [ "$yn" = "N" ] || [ "$yn" = "N" ]; then
		printf "\n * Please run 'snaq-seq.sh -h' for more information. * \n "
        	exit 1
	fi
done

# Request for genome indices.
while true; do
        printf "* Does your reference genome data include bwa indices? \nIf yes, please make sure they are located in the same folder where the reference genome is, the file path will be asked for. \nIf no, the analysis will build the bwa indices on the fly. \n "
        read -r -p " Type [Y/N]: " ref_yn
        ref_yn=$(echo $(echo -e "$ref_yn" | tr -d '[:space:]'))
	        if [ "$ref_yn" = "Y" ] || [ "$ref_yn" = "y" ] || [ "$ref_yn" = "N" ] || [ "$ref_yn" = "n" ]; then
                break
        fi
done

# If genome indices available acquire from user. 
if [ "$ref_yn" = "Y" ] || [ "$ref_yn" = "y" ]; then
	while true; do
		read -r -p "* Please provide the file path (no file names) of the indices location (reference genome must be located in same path): " user_indices
                user_indices=$(echo $(echo -e "$user_indices" | tr -d '[:space:]'))
                	if [ "$(echo -n $user_indices | tail -c 1)" = '/' ]; then
                        	user_indices=$(echo "${user_indices}")
			fi
				break			
	done
fi 

# If genome indices unavailable acquire response.
if [ "$ref_yn" = "N" ] || [ "$ref_yn" = "n" ]; then
	while true; do
		printf "\n* Do you want to keep the bwa indices that will be generated for future analysis?:\n"
        	read -r -p " Type [Y/N]: " yn_indices
        	yn_indices=$(echo $(echo -e "$yn_indices" | tr -d '[:space:]'))	
			break
	done
fi

genome_prefix=$(echo ${3} | sed 's/\//\t/g' | sed 's/\t/\n/g'| tail -1)

# If options verified and genome indices made available from user.
if [ "$yn" = "Y" ] || [ "$yn" = "y" ] && [ "$ref_yn" = "Y" ] || [ "$ref_yn" = "y" ] ; then
	printf "\n* Snaq-seq is preparing to launch... \n\n"
	docker run  -e mfs="$6" -e rc="$7" -e mpq="$8" -e qc="$9" -e cc="${10}" -e is=${11} -e ref_yn=$ref_yn -e genome_prefix=$genome_prefix -v $1:/home/data/input  -v $2:/home/data/output -v $user_indices:/home/data/ref -v $3:/home/data/ref_backup/genome.fasta  -v $4:/home/data/basechange/reference_amplicon.fasta -v $5:/home/data/normalization/amplicon_adjustment.txt -ti accugenomics/snaq-seq:v1 bash /snaq-seq/init.sh

# If options verified and genome indices not made avaialble from user.
	elif [ "$yn" = "Y" ] || [ "$yn" = "y" ] && [ "$ref_yn" = "N" ] || [ "$ref_yn" = "N" ] ; then
        printf "\n* Snaq-seq is preparing to launch... \n\n"
	docker run  -e mfs="$6" -e rc="$7" -e mpq="$8" -e qc="$9" -e cc="${10}" -e is=${11} -e ref_yn=$ref_yn -e yn=$yn_indices  -v $1:/home/data/input  -v $2:/home/data/output -v $3:/home/data/ref/genome.fasta  -v $4:/home/data/basechange/reference_amplicon.fasta -v $5:/home/data/normalization/amplicon_adjustment.txt -ti accugenomics/snaq-seq:v1   bash /snaq-seq/init.sh
	

fi

