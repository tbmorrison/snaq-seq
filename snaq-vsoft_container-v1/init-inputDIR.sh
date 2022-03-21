#!/usr/bin/env bash
# author: "Thahmina A. Ali"


export PATH=$PATH:/snaq-seq/
export PATH=$PATH:/home/



if [ $outsam = "outputSAM=0" ]; then
		echo " ls /home/data/input/*_R1_* |  awk 'BEGIN {FS=\"_R1|/\"};  {print \"\"\$5\"\t$option0 $option1 $option2 $option3 $option4 $option5 $option6 $option7 $option8 $option9 $option10 $option11 $option12 $option13 $option14 $option15\"}' > /home/output/TIME/commandLine.txt" > /home/output_1.sh
                date=$(stat /home/data/input/ | grep Modify | sed 's/\s/\t/g' | cut -f2,3 | sed 's/[.].*$//' | sed 's/\t/ /g')
                echo " ls /home/data/input/*_R1_* |  awk 'BEGIN {FS=\"_R1|/\"};  {print \"\"\$5\"\t$date\t$inputDIR\"\$5\"_R1\"\$6\";$inputDIR\"\$5\"_R2\"\$6\"\"}' > /home/output/TIME/fastqCreationDate.txt" > /home/output_2.sh
		perl /snaq-seq/snaq-seq_core.pl $inputDIR $genome_fasta $outsam $ofs $mfs $rc $mpq $qc $gbc $outis $cc $is 

fi

if [ $outsam = "outputSAM=1" ]; then
		echo " ls /home/data/input/*_R1_* |  awk 'BEGIN {FS=\"_R1|/\"};  {print \"\"\$5\"\t$option0 $option1 $option2 $option3 $option4 $option5 $option6 $option7 $option8 $option9 $option10 $option11 $option12 $option13 $option14 $option15\"}' > /home/output/TIME/commandLine.txt" > /home/output_1.sh
                date=$(stat /home/data/input/ | grep Modify | sed 's/\s/\t/g' | cut -f2,3 | sed 's/[.].*$//' | sed 's/\t/ /g')
		echo " ls /home/data/input/*_R1_* |  awk 'BEGIN {FS=\"_R1|/\"};  {print \"\"\$5\"\t$date\t$inputDIR\"\$5\"_R1\"\$6\";$inputDIR\"\$5\"_R2\"\$6\"\"}' > /home/output/TIME/fastqCreationDate.txt" > /home/output_2.sh
                perl /snaq-seq/snaq-seq_core-sam.pl $inputDIR $genome_fasta $outsam $ofs $mfs $rc $mpq $qc $gbc $outis $cc $is
fi


echo ''
echo '******************************************************'
echo '*                                                    *'
echo '*                                                    *'
echo '*        Snaq-seq analysis complete...               *'
echo '*                                                    *'
echo '******************************************************'
echo ''
wait 
echo "Snaq-seq run end time: $(date +%T)"
echo ''

exit
