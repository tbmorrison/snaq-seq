# author: "Thahmina A. Ali"

ls /home/data/input/*_R1_* | awk 'BEGIN {FS="_R1|/"};  {print "bash /home/"$5"_snaq-seq.sh  2>>  /home/error2 "}' > snaq-seq_launch_list.sh
