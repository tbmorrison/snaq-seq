# make_dir.sh
#
# author: "Thahmina A. Ali"
#
# Usage: accessory script to create/initate alignment launch_list files; please refer to README.md for program flow and further information.


ls /home/data/input/*_R1_* | awk 'BEGIN {FS="_R1|/"};  {print "mkdir /home/output/TIME/"$5"  &"}' > make_dir_list.sh

