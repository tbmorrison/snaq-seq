
perl -ne 'if (/^>(\S+)/) { close OUT; open OUT, ">$1.fasta" } print OUT' "${ref}"; sed -i '1d' "./"*"SNAQ"*"fasta";

ls *SNAQ*fasta | awk '{print "awk -i inplace '\''{ gsub(/./,\"&\\n\",$1); print $1 }'\'' "$0"; sed -i '\''/^[[:space:]]*$/d'\'' "$0" "}' > ./map.sh ; bash ./map.sh;

ls *SNAQ-NT.fasta | awk '{print "awk '\''BEGIN {FS=\"-\"}; {print FILENAME\"\\t\"$0}'\'' "$0"  | sed '\''s/-/\\t/g'\'' | awk '\''{print $2\"-\"NR\"\\t\"$1\"-\"$2\"-\"$3\"-\"$4\"-\"$5\"\\t\"NR\"\\t\"$6}'\''| sed '\''s/.fasta//g'\''  > "$0"_v1"}' > ./bc_NT.sh ; bash ./bc_NT.sh;

ls *SNAQ-IS.fasta | awk '{print "awk '\''BEGIN {FS=\"-\"}; {print FILENAME\"\\t\"$0}'\'' "$0"  | sed '\''s/-/\\t/g'\'' | awk '\''{print $2\"-\"NR\"\\t\"$1\"-\"$2\"-\"$3\"-\"$4\"-\"$5\"\\t\"NR\"\\t\"$6}'\'' | sed '\''s/.fasta//g'\'' > "$0"_v1"}' > ./bc_IS.sh ; bash ./bc_IS.sh;

ls *_v1 | awk 'BEGIN {FS="SNAQ-"}; {print "join -t $'\''\\t'\'' -1 1 -2 1 -o 1.2,1.3,1.4,2.2,2.3,2.4 <(sort -k1 " $1 "SNAQ-NT.fasta_v1) <(sort -k1 " $1 "SNAQ-IS.fasta_v1) > " $1 "SNAQ_v2 ;"}' > ./bc_NT_IS.sh ; bash ./bc_NT_IS.sh;

cat *v2 > basechange_v2.txt; sort -V -k4,4 -k5,5 basechange_v2.txt > basechange_v3.txt;

ls *SNAQ-CC.fasta | awk '{print "awk '\''BEGIN {FS=\"-\"}; {print FILENAME\"\\t\"$0}'\'' "$0"  | sed '\''s/-/\\t/g'\'' | awk '\''{print $2\"-\"NR\"\\t\"$1\"-\"$2\"-\"$3\"-\"$4\"-\"$5\"\\t\"NR\"\\t\"$6}'\''| sed '\''s/.fasta//g'\''  > "$0"_v1"}' > ./bc_CC.sh ; bash ./bc_CC.sh;

cat *SNAQ-NT.fasta_v1 > MID121-Amp000-000-SNAQ-NT.fasta_v1;

cat *SNAQ-IS.fasta_v1 > MID121-Amp000-000-SNAQ-IS.fasta_v1;

ls *-001-SNAQ-CC.fasta_v1 | awk 'BEGIN {FS="SNAQ-"}; {print "join -t $'\''\\t'\'' -1 1 -2 1 -o 1.2,1.3,1.4,2.2,2.3,2.4 <(sort -k1 MID121-Amp000-000-SNAQ-NT.fasta_v1) <(sort -k1 "$0") > ./"$1"SNAQ_NT-CC_v2 ;"}' > ./bc_NT_CC.sh ; bash ./bc_NT_CC.sh;

cat ./*SNAQ_NT-CC_v2 > ./basechange_v4.txt; sort -V -k4,4 -k5,5 ./basechange_v4.txt > ./basechange_v5.txt;

ls *-001-SNAQ-CC.fasta_v1 | awk 'BEGIN {FS="SNAQ-"}; {print "join -t $'\''\\t'\'' -1 1 -2 1 -o 1.2,1.3,1.4,2.2,2.3,2.4  <(sort -k1 MID121-Amp000-000-SNAQ-IS.fasta_v1) <(sort -k1 "$0") > ./"$1"SNAQ_IS-CC_v2 ;"}' > ./bc_IS_CC.sh ; bash ./bc_IS_CC.sh;

cat ./*SNAQ_IS-CC_v2 > ./basechange_v6.txt; sort -V -k4,4 -k5,5 ./basechange_v6.txt > ./basechange_v7.txt;

cat ./basechange_v3.txt ./basechange_v5.txt ./basechange_v7.txt > ./amplicon-basechange.txt; sed  -i '1i NT_CHROM\tNT_POS\tNT_REF\tIS_CHROM\tIS_POS\tIS_REF' ./amplicon-basechange.txt

cp ./amplicon-basechange.txt $(dirname "${ref}")
