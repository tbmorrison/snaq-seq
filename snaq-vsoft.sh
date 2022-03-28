#!/usr/bin/env bash
# Author: "Thahmina A. Ali"



#Display Help.
Help()
{
   # Display Help
   echo " "
   echo "     SNAQ-Vsoft: QC for viral surveillance NGS testing.     "
   echo
   echo FOLDER Usage:
   echo
   echo "bash snaq-vsoft.sh inputDIR=/home/input/fastq/ output=/home/output/ rg=/home/input/reference_genome.fasta bc=/home/input/amplicon_basechange.txt norm=/home/input/normalization.txt outputSAM=0 ofsCutoff=0.01 mfs=0 RC=1 mapq=-1 qCutoff=0  gbc=1 outputIS=0 CC=300 IS=300 VERSION=v1"
   echo
   echo SINGLE SAMPLE Usage:
   echo
   echo "bash snaq-vsoft.sh inputFILE=/home/input/fastq/foward_R1.fastq,/home/input/fastq/reverse_R2.fastq output=/home/output/ rg=/home/input/reference_genome.fasta bc=/home/input/amplicon_basechange.txt norm=/home/input/normalization.txt outputSAM=0 ofsCutoff=0.01 mfs=0 RC=1 mapq=-1 qCutoff=0  gbc=1 outputIS=0 CC=300 IS=300 VERSION=v1"
   echo
   echo "Options:"
   echo
   echo "There are a total of 16 options (depending on the input option, at least 1 filepath(s), at least 3 filenames, 9 integer values, 1 float value) to be provided in the following order on the command line:"
   echo " "
   echo "1)  inputDIR=                  Location folder path to fastq.gz files (folder should ONLY consist of fastq input)."
   echo "                     OR                                                                                        "
   echo	"    inputFILE=                 Location file path of forward AND reverse fastq.gz files seperated by comma."			
   echo "2)  output=                    Location folder path to place analysis outputs."
   echo "3)  rg=       	               Location file path of reference genome (fasta format). The path must include bwa indices."
   echo "4)  bc=                        Location file path of basechange file."
   echo "5)  norm=                      Location file path of IS amplicon adjustment (normalization) file (tab seperated format)."
   echo "6)  outputSAM=                 Alignment output in SAM format (0=False, 1=True) (integer value)."
   echo "7)  ofsCutoff=                 offspring Cutoff (0 < ofsCutoff < 1)."
   echo "8)  mfs=                       Minimum fragment size (integer value)."
   echo "9)  RC=                        RC (integer value)."
   echo "10) mapq=                      Mapping quality (accepts both positive and negative integer values)."
   echo "11) qCutoff=                   QC cutoff (integer value)."
   echo "12) gbc=                       basechange (integer value)."
   echo "13) outputIS=                  Include IS sequences in fastq output (0=False, 1=True) (integer value)."
   echo "14) CC=                        Complexity control copies (integer value)."
   echo "15) IS=                        Internal standards (integer value)."
   echo "16) VERSION=                   v1 (latest version)."
   echo
   echo "Additional options:"
   echo 
   echo "-b			       Location file path of reference amplicon (fasta format)."
   echo
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
	echo -e "***\n [ERROR] No options were provided. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
    	exit 1
fi

# Handle more than 16 options.
ARGS=16
if [ $# -gt "$ARGS" ]; then
	echo -e "\n *** [ERROR] -  Too many options were provided. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
    	exit 1
fi

# Handle less than 16 options.
ARGS=16
if [[ ! "$1" == "-b" ]]; then
	if [ $# -lt "$ARGS" ]; then
		echo -e "***\n [ERROR] - Wrong number of options were provided. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
    		exit 1
	fi
fi


arg_1_option1=$(echo ${1} | sed 's/=.*/=/g')
arg_2_option1=$(echo ${1} | sed 's/.*=//g')
arg_3_option1=$(echo ${1} | sed 's/.*\.//g')
arg_4_option1=$(echo ${1} | sed 's/.*\.//g')
arg_5_option1=$(echo ${1} | sed 's/.*=//g' | sed 's/,/\n/g'| head -1)
arg_6_option1=$(echo ${1} | sed 's/.*=//g' | sed 's/,/\n/g'| tail -1)

arg_1_option3=$(echo ${3} | sed 's/=.*/=/g')
arg_2_option3=$(echo ${3} | sed 's/.*\.//g')
arg_3_option3=$(echo ${3} | sed 's/.*=//g')
arg_4_option3=$(echo ${3} | sed 's/.*=//g' | sed 's/.fasta/.fasta.amb/g')
arg_5_option3=$(echo ${3} | sed 's/.*=//g' | sed 's/.fasta/.fasta.ann/g')
arg_6_option3=$(echo ${3} | sed 's/.*=//g' | sed 's/.fasta/.fasta.bwt/g')
arg_7_option3=$(echo ${3} | sed 's/.*=//g' | sed 's/.fasta/.fasta.fai/g')
arg_8_option3=$(echo ${3} | sed 's/.*=//g' | sed 's/.fasta/.fasta.sa/g')
arg_9_option3=$(echo ${3} | sed 's/.*=//g' | sed 's/.fasta/.fasta.pac/g')

arg_1_option4=$(echo ${4} | sed 's/=.*/=/g')
arg_2_option4=$(echo ${4} | sed 's/.*\.//g')
arg_3_option4=$(echo ${4} | sed 's/.*=//g')

arg_1_option5=$(echo ${5} | sed 's/=.*/=/g')
arg_2_option5=$(echo ${5} | sed 's/.*\.//g')
arg_3_option5=$(echo ${5} | sed 's/.*=//g')


arg_1_option2=$(echo ${2} | sed 's/=.*/=/g')
arg_1_option6=$(echo ${6} | sed 's/=.*/=/g')
arg_1_option7=$(echo ${7} | sed 's/=.*/=/g')
arg_1_option8=$(echo ${8} | sed 's/=.*/=/g')
arg_1_option9=$(echo ${9} | sed 's/=.*/=/g')
arg_1_option10=$(echo ${10} | sed 's/=.*/=/g')
arg_1_option11=$(echo ${11} | sed 's/=.*/=/g')
arg_1_option12=$(echo ${12} | sed 's/=.*/=/g')
arg_1_option13=$(echo ${13} | sed 's/=.*/=/g')
arg_1_option14=$(echo ${14} | sed 's/=.*/=/g')
arg_1_option15=$(echo ${15} | sed 's/=.*/=/g')
arg_1_option16=$(echo ${16} | sed 's/=.*/=/g')


arg_2_option2=$(echo ${2} | sed 's/.*=//g')
arg_2_option6=$(echo ${6} | sed 's/.*=//g') 
arg_2_option7=$(echo ${7} | sed 's/.*=//g')
arg_2_option8=$(echo ${8} | sed 's/.*=//g')
arg_2_option9=$(echo ${9} | sed 's/.*=//g')
arg_2_option10=$(echo ${10} | sed 's/.*=//g')
arg_2_option11=$(echo ${11} | sed 's/.*=//g')
arg_2_option12=$(echo ${12} | sed 's/.*=//g')
arg_2_option13=$(echo ${13} | sed 's/.*=//g')
arg_2_option14=$(echo ${14} | sed 's/.*=//g') 
arg_2_option15=$(echo ${15} | sed 's/.*=//g')
arg_2_option16=$(echo ${16} | sed 's/.*=//g')

if [[ "$1" == "-b" ]]; then
        if [[ ! -f "$2" ]]; then
        	echo -e "***\n [ERROR] - Basechange fasta file does not exist... *** \n"
                exit 1
	fi
fi

if [[ "$1" == "-b" ]]; then
	if [[ -f "$2" ]]; then
		suffix=$(echo ${2} | sed 's@.*/@@' | sed 's/.*.f/f/g')
		if [[ ! "$suffix" == "fasta" ]]; then 
        		output=false
			echo -e "***\n [ERROR] - Wrong filetype provided... *** \n"
        		exit 1
		fi
	fi
elif [[ "$1" == "-b" ]]; then
	if [[ -f "$2" ]]; then
		suffix=$(echo ${2} | sed 's@.*/@@' | sed 's/.*.f/f/g')
        	if [[ ! "$suffix" == "fa" ]]; then 
			output=false
			echo -e "***\n [ERROR] - Wrong filetype provided... *** \n"
        		exit 1
		fi
	fi
else
	output=true
fi


if [[ "$1" == "-b" ]]; then
	if [[ -f "$2" ]]; then
	       suffix=$(echo ${2} | sed 's@.*/@@' | sed 's/.*.f/f/g')
	       if [[ "$suffix" == "fasta" ]] || [[ "$suffix" == "fa" ]]; then
	       output=true
               bc_prefix=$(echo ${2} | sed 's@.*/@@' | sed 's/\..*//g')
               bc_output=$(echo ${2} | sed 's/\/[^/]*$/\//')
       	       docker pull accugenomics/snaq-seq:pre
	       docker run --rm -e bc_prefix="$bc_prefix" -e bc_output="$bc_output" -v $2:/home/basechange/reference_amplicon.fasta  -v $bc_output:/home/basechange/ -ti accugenomics/snaq-seq:pre /bin/bash /preliminary/init_bc.sh
	       fi
	       exit
	fi	
else
	output=false
fi


if [[ ! "$1" == "-b" ]]; then
	if [[ ! "$arg_1_option1" == "inputDIR=" ]]; then
		if [[ ! "$arg_1_option1" == "inputFILE=" ]]; then
			output=false
			echo -e "***\n [ERROR] - The 'input' option is incorrect. Please run 'snaq-vsoft.sh -h' for more information on 'inputDIR' and 'inputFILE'. *** \n"
        		exit 1
		fi
	fi
else 
	output=true
fi



if [ "$arg_1_option1" == "inputFILE=" ]; then
	if [[ ! -f "$arg_5_option1" ]] || [[ ! -f "$arg_6_option1" ]]; then 
        	output=false
		echo -e "***\n [ERROR] - The 'inputFILE=' option is missing fastq(s). Please run 'snaq-vsoft.sh -h' for more information. *** \n"
		exit 1
	fi
else 
	output=true
fi

if [[  "$arg_1_option1" == "inputDIR=" ]]; then
	if [[ ! -d "$arg_2_option1" ]]; then
		output=false
        	echo -e "***\n [ERROR] - The 'inputDIR=' option is provided with no directory. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	fi
else
	output=true

fi

# check validity of heads of fastq files
if [[ "$arg_1_option1" == "inputFILE=" ]]; then
    IFS="," read -r -a fastq_filenames <<< "$arg_2_option1"
elif [[ "$arg_1_option1" == "inputDIR=" ]]; then
    fastq_filenames=("$arg_2_option1"/*.fastq.gz)
fi

for file in "${fastq_filenames[@]}"; do
    # check line1 of compressed fastq files starts with a '@' character
    line1=`zcat < $file | head -1`
    if [[ ! "$line1" =~ ^\@ ]]; then
	echo -e "***\n [ERROR] - input fastq.gz files are not valid format. Please check input file validity. *** \n"
    	exit 1
    fi

    # check sequence lines match lengths of quality scores for first 40 lines (additional check)
    len_int=`zcat < $file | head -40 | paste - - - - | awk -F"\t" '{ if (length($2) != length($4)) print $0 }' | wc -l`
    if [[ ! "$len_int" -eq "0" ]]; then
	echo -e "***\n [ERROR] - input fastq.gz files are not valid format. Please check input file validity. *** \n"
    	exit 1
    fi
done


if [[ ! "$1" == "-b" ]]; then
	if [[ ! "$arg_1_option2" == "output=" ]]; then
        	output=false
        	echo -e "***\n [ERROR] - The 'output=' option is incorrect. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	fi
fi

if [[ ! "$1" == "-b" ]]; then
	if [[ ! -d "$arg_2_option2" ]]; then
	        output=false
	        echo -e "***\n [ERROR] - The 'output=' option is provided with no existing directory. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
	        exit 1
	fi
else
        if [ "$arg_1_option2" == "output=" ] && [ -d "$arg_2_option2" ]; then
        output=true
        fi
fi


if [[ ! "$1" == "-b" ]]; then
	if [[ ! "$arg_1_option3" == "rg=" ]]; then
        	output=false
        	echo -e "***\n [ERROR] - The 'rg=' option is incorrect. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	fi
fi

if [[ ! "$1" == "-b" ]]; then
	if [[ ! -f "$arg_3_option3" ]]; then
        	output=false
        	echo -e "***\n [ERROR] - The 'rg=' option is provided with no file. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	elif [ -f "$arg_3_option3" ]; then
		if [ "$arg_2_option3" == "fa" ] || [ "$arg_2_option3" == "fasta" ]; then
			if [[ ! -f "$arg_4_option3" ]] && [[ ! -f "$arg_5_option3" ]] && [[ ! -f "$arg_6_option3" ]] && [[ ! -f "$arg_7_option3" ]] && [[ ! -f "$arg_8_option3" ]] && [[ ! -f "$arg_9_option3" ]]; then
				output=false 
				echo -e "***\n [ERROR] - The genome file and indices are incorrect. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
				exit 1
			fi
		fi
	elif [[ ! "$arg_2_option3" == "fa" ]]; then
        	output=false
        	echo -e "***\n [ERROR] - The 'rg=' option filetype is incorrect. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	elif [[ ! "$arg_2_option3" == "fasta" ]]; then
        	output=false
        	echo -e "***\n [ERROR] - The 'rg=' option filetype is incorrect. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	else
		output=true
	fi
fi 


if [[ ! "$1" == "-b" ]]; then
	if [[ ! "$arg_1_option4" == "bc=" ]]; then
        	output=false
        	echo -e "***\n [ERROR] - The 'bc=' option is incorrect. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	fi
fi

if [[ ! "$1" == "-b" ]]; then
	if [[ ! -f "$arg_3_option4" ]]; then
        	output=false
        	echo -e "***\n [ERROR] - The 'bc=' option is provided with no file. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	elif [ "$arg_1_option4" == "bc=" ] && [ "$arg_2_option4" == "txt" ]; then
        	output=true
	else
        	output=false
        	echo -e "***\n [ERROR] - The basechange file type is incorrect. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	fi
fi


if [[ ! "$1" == "-b" ]]; then
	if [[ ! "$arg_1_option5" == "norm=" ]]; then
        	output=false
        	echo -e "***\n [ERROR] - The 'norm=' option is incorrect. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	fi
fi

if [[ ! "$1" == "-b" ]]; then
	if [[ ! -f "$arg_3_option5" ]]; then
        	output=false
        	echo -e "***\n [ERROR] - The 'norm=' option is provided with no file. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	elif [ "$arg_1_option5" == "norm=" ] && [ "$arg_2_option5" == "txt" ]; then
        	output=true
	else
        	output=false
        	echo -e "***\n [ERROR] - The normalization file type is incorrect. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	fi
fi

if [[ ! "$1" == "-b" ]]; then
	if [[ ! "$arg_1_option6" == "outputSAM=" ]]; then
        	output=false
        	echo -e "***\n [ERROR] - The 'outputSAM=' option is incorrect. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	elif [ "$arg_1_option6" == "outputSAM=" ] && [ "$arg_2_option6" == "0" ]; then
        	output=true
	elif [ "$arg_1_option6" == "outputSAM=" ] && [ "$arg_2_option6" == "1" ]; then
        	output=true
	else
        	output=false
		echo -e "***\n [ERROR] - The outputSAM value is incorrect. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	fi
fi

if [[ ! "$1" == "-b" ]]; then
	if [[ ! "$arg_1_option7" == "ofsCutoff=" ]]; then
        	output=false
        	echo -e "***\n [ERROR] - The 'ofsCutoff=' option is incorrect. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	elif [ "$arg_1_option7" == "ofsCutoff=" ] && [[  "$arg_2_option7" =~ ^[0]\.[0-9]+$ ]] ; then
        	output=true
	else
        	output=false
        	echo -e "***\n [ERROR] - The ofsCutoff value is incorrect. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	fi
fi


if [[ ! "$1" == "-b" ]]; then
	if [[ ! "$arg_1_option8" == "mfs=" ]]; then
        	output=false
        	echo -e "***\n [ERROR] - The 'mfs=' option is incorrect. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	elif [ "$arg_1_option8" == "mfs=" ] && [[  "$arg_2_option8" =~  ^-?[0-9]+$ ]]; then
        	output=true
	else
        	output=false
        	echo -e "***\n [ERROR] - The mfs value is incorrect. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	fi
fi

if [[ ! "$1" == "-b" ]]; then
	if [[ ! "$arg_1_option9" == "RC=" ]]; then
        	output=false
        	echo -e "***\n [ERROR] - The 'RC=' option is incorrect. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	elif [ "$arg_1_option9" == "RC=" ] && [[  "$arg_2_option9" =~ ^[1-9]+$ ]]; then
        	output=true
	else
        	output=false
        	echo -e "***\n [ERROR] - The RC value is incorrect. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	fi
fi

if [[ ! "$1" == "-b" ]]; then
	if [[ ! "$arg_1_option10" == "mapq=" ]]; then
        	output=false
        	echo -e "***\n [ERROR] - The 'mapq=' option is incorrect. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	elif [ "$arg_1_option10" == "mapq=" ] && [[  "$arg_2_option10" =~ ^-?[0-9]+$ ]]; then
        	output=true
	else
        	output=false
        	echo -e "***\n [ERROR] - The mapq value is incorrect. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	fi
fi

if [[ ! "$1" == "-b" ]]; then
	if [[ ! "$arg_1_option11" == "qCutoff=" ]]; then
        	output=false
        	echo -e "***\n [ERROR] - The 'qCutoff=' option is incorrect. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	elif [ "$arg_1_option11" == "qCutoff=" ] && [[  "$arg_2_option11" =~ ^-?[0-9]+$ ]]; then
        	output=true
	else
        	output=false
        	echo -e "***\n [ERROR] - The qCutoff value is incorrect. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	fi
fi

if [[ ! "$1" == "-b" ]]; then
	if [[ ! "$arg_1_option12" == "gbc=" ]]; then
        	output=false
        	echo -e "***\n [ERROR] - The 'gbc=' option is incorrect. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	elif [ "$arg_1_option12" == "gbc=" ] && [[  "$arg_2_option12" =~ ^[1-9]+$ ]]; then
        	output=true
	else
        	output=false
        	echo -e "***\n [ERROR] - The gbc value is incorrect. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	fi
fi

if [[ ! "$1" == "-b" ]]; then
	if [[ ! "$arg_1_option13" == "outputIS=" ]]; then
        	output=false
        	echo -e "***\n [ERROR] - The 'outputIS=' option is incorrect. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	elif [ "$arg_1_option13" == "outputIS=" ] && [ "$arg_2_option13" == "0" ]; then
        	output=true
	elif [ "$arg_1_option13" == "outputIS=" ] && [ "$arg_2_option13" == "1" ]; then
        	output=true
	else
        	output=false
        	echo -e "***\n [ERROR] - The outputIS value is incorrect. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	fi
fi

if [[ ! "$1" == "-b" ]]; then
	if [[ ! "$arg_1_option14" == "CC=" ]]; then
        	output=false
        	echo -e "***\n [ERROR] - The 'CC=' option is incorrect. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	elif [ "$arg_1_option14" == "CC=" ] && [[  "$arg_2_option14" =~ ^[0-9]+$ ]]; then
        	output=true
	else
        	output=false
        	echo -e "***\n [ERROR] - The CC value is incorrect. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	fi
fi

if [[ ! "$1" == "-b" ]]; then
	if [[ ! "$arg_1_option15" == "IS=" ]]; then
        	output=false
        	echo -e "***\n [ERROR] - The 'IS=' option is incorrect. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	elif [ "$arg_1_option15" == "IS=" ] && [[  "$arg_2_option15" =~ ^[0-9]+$ ]]; then
        	output=true
	else
        	output=false
        	echo -e "***\n [ERROR] - The IS value is incorrect. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
        	exit 1
	fi
fi

if [[ ! "$1" == "-b" ]]; then
        if [[ ! "$arg_1_option16" == "VERSION=" ]]; then
                output=false
                echo -e "***\n [ERROR] - The 'VERSION=' option is incorrect. Please run 'snaq-vsoft.sh -h' for more information. *** \n"
                exit 1
        fi
fi


# Verify Linux environment.
if [[ ! "$1" == "-b" ]]; then
	if [ "$(expr substr $(uname -s) 1 5)" = "Linux" ]; then
    		user_os="Linux"
        	printf "\n\nLinux system verified...\n\n"
	else
        	printf "** [ERROR] - Snaq-seq only supports Linux systems.\n\t Please run snaq-seq on a Linux environment. \n"
        	exit 1
	fi
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

# Gather options and verify user options
if [[ ! "$1" == "-b" ]]; then
echo -e "\nGathering options...Verifying user options... \n";
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
echo "${15}";
echo -e "${16} \n";
fi

option0=$(echo ${0})
option1=$(echo ${1})
option2=$(echo ${2})
option3=$(echo ${3})
option4=$(echo ${4})
option5=$(echo ${5})
option6=$(echo ${6})
option7=$(echo ${7})
option8=$(echo ${8})
option9=$(echo ${9})
option10=$(echo ${10})
option11=$(echo ${11})
option12=$(echo ${12})
option13=$(echo ${13})
option14=$(echo ${14})
option15=$(echo ${15})
option16=$(echo ${16})

input=$(echo ${1} | sed 's/=.*//g')
inputDIR=$(echo ${1} |sed 's/.*=//g')
inputFILE_fasta=$(echo ${1} | sed 's/.*=//g'| sed 's/,/\n/g' | head -1 | sed 's@.*/@@' | sed 's/_R.*//g') 
inputFILE_path=$(echo ${1} | sed 's/.*=//g'| sed 's/,/\n/g' | head -1 | sed 's/\/[^/]*$/\//')


output=$(echo ${2} |sed 's/.*=//g')
ref=$(echo ${3} |sed 's/.*=//g')
bc_amp=$(echo ${4} |sed 's/.*=//g')
norm_amp=$(echo ${5} |sed 's/.*=//g')
genome_fasta=$(echo ${ref} | sed 's@.*/@@')
genome_path=$(echo ${ref} | sed 's/\/[^/]*$/\//')


# check fasta file header
if [[ ! "$1" == "-b" ]]; then
ref_line1=$(sed -n '/^>/p;q' "$ref")
	if [[ ! "$ref_line1" =~ ^\> ]]; then
    		echo -e "***\n [ERROR] - The reference genome file is not a valid .fasta format. Please check input file validity. *** \n"
	exit 1
	fi
fi



# Get array of tags for accugenomics/snaq-seq
tags=`wget -q https://registry.hub.docker.com/v1/repositories/accugenomics/snaq-seq/tags -O - | sed -e 's/[][]//g' -e 's/[{}]//g' -e 's/"//g' -e 's/layer: //g' -e 's/name: //g'`
tags_arr=($(echo "$tags" | tr ',' '\n'))
tag_sel=$(echo ${16} | sed 's/VERSION=//g')
if [[ ! "$1" == "-b" ]]; then
	if [ ${tag_sel} = "v1" ];  then
    		pull_cmd="docker pull accugenomics/snaq-seq:$tag_sel"
    		eval $pull_cmd
	elif [[ ! ${tags_arr[*]} =~ $tag_sel ]]; then
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
fi



#If input is receiving directory and  options verified from user.
if [ $input = "inputDIR" ] ; then 
    docker run --rm -e inputDIR="$inputDIR" -e genome_fasta="$genome_fasta" -e outsam="$6" -e ofs="$7" -e mfs="$8" -e rc="$9" -e mpq="${10}" -e qc="${11}"  -e gbc="${12}" -e outis=${13}  -e cc="${14}" -e is=${15} -e option0=$option0 -e option1=$option1 -e option2=$option2 -e option3=$option3 -e option4=$option4 -e option5=$option5 -e option6=$option6 -e option7=$option7 -e option8=$option8 -e option9=$option9 -e option10=$option10 -e option11=$option11 -e option12=$option12 -e option13=$option13 -e option14=$option14 -e option15=$option15  -v $inputDIR:/home/data/input  -v $output:/home/data/output -v $genome_path:/home/data/ref  -v $bc_amp:/home/data/basechange/amplicon_basechange.txt -v $norm_amp:/home/data/normalization/amplicon_normalization.txt -ti accugenomics/snaq-seq:$tag_sel /bin/bash /snaq-seq/init-inputDIR.sh  
fi

# If input is receiving single fastq set and options verified from user.
if  [ $input = "inputFILE" ] ; then 
    docker run --rm -e inputFILE_fasta="$inputFILE_fasta" -e  genome_fasta="$genome_fasta"  -e outsam="$6" -e ofs="$7" -e mfs="$8" -e rc="$9" -e mpq="${10}" -e qc="${11}"  -e gbc="${12}" -e outis=${13}   -e cc="${14}" -e is=${15}  -e option1=$option1 -e option2=$option2 -e option3=$option3 -e option4=$option4 -e option5=$option5 -e option6=$option6 -e option7=$option7 -e option8=$option8 -e option9=$option9 -e option10=$option10 -e option11=$option11 -e option12=$option12 -e option13=$option13 -e option14=$option14 -e option15=$option15 -v $inputFILE_path:/home/data/input  -v $output:/home/data/output -v $genome_path:/home/data/ref  -v $bc_amp:/home/data/basechange/amplicon_basechange.txt -v $norm_amp:/home/data/normalization/amplicon_normalization.txt -ti accugenomics/snaq-seq:$tag_sel /bin/bash #/snaq-seq/init-inputFILE.sh 
fi

exit
