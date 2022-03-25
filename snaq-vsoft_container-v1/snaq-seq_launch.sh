# snaq-seq_launch.sh
#
# author: "Thahmina A. Ali"
#
# Usage: accessory script to create/initate alignment launch_list files; please refer to README.md for program flow and further information.

ls /home/data/input/*_R1_* | awk 'BEGIN {FS="_R1|/"};  {print "bash /home/"$5"_snaq-seq.sh  2>>  /home/error2 "}' > snaq-seq_launch_list.sh
