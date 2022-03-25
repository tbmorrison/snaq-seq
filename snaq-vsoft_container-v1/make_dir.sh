# author: "Thahmina A. Ali"
# Refer to the README and flowchart
# Creates working directory to perform the analysis.


ls /home/data/input/*_R1_* | awk 'BEGIN {FS="_R1|/"};  {print "mkdir /home/output/TIME/"$5"  &"}' > make_dir_list.sh

