#!/usr/bin/awk
## Usage: pipe paired sam reads, converts to fastq
{
	split($0,a,"\t")
	foundPair=0
	while (!foundPair){
		getline
		if (a[1]==$1){
			print "@" a[1] "\n" a[10] "\n+\n" a[11] > (file1)
			print "@" $1 "\n" $10 "\n+\n" $11 > (file2)
			foundPair=1
		} else {
			np++
			split($0,a,"\t")
		}
	}
}
END {
#	print "number of single reads: " np > "/dev/stderr"
}
