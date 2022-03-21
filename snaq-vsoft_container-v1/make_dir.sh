# author: "Thahmina A. Ali"

ls /home/data/input/*_R1_* | awk 'BEGIN {FS="_R1|/"};  {print "mkdir /home/output/TIME/"$5"  &"}' > make_dir_list.sh

