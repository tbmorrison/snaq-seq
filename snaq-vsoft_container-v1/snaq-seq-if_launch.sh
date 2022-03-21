# author: "Thahmina A. Ali"

ls /home/data/input/FILE_R1_* | awk 'BEGIN {FS="_R1|/"};  {print "bash /home/FILE_snaq-seq.sh  2>>  /home/error2 "}' > snaq-seq_launch_list.sh
