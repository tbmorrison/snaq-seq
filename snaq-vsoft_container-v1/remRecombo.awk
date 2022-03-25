#!/usr/bin/awk

##usage: remRecombo.awk -v RC=recombinants per read cutoff
##	-v minFragSize don't accept fragments smaller value.  bwa mem adds N's for <35 size frag causing NM estimate to be off
##	-v RC less than this value are acceptable recombinant events per read.
##	-v mapq=minimal MAPQ score
##	-v qCutoff=minimum qscore to count base change position or recombinant positive.
##	-v gbc=required number basechanges per fragment
##	-v outputIS=0 or 1 for outputting IS reads
##	-v sampleName=Associate various QC counts with sample name
##	-v offspringCutoff default should be 0.01, used to set CC replicate background rate cuttoff
##	-v samOutput = 0 or 1, 1 output sam files.
##	-v <baseChangeFile.txt> path to base change file
##	-v resultsPath path to where the SNAQ analysis files end up
##	-v single= 1 if single read bam, or 0 if paired reads
##	<sam> same file or stdout stream from bwa meme, read pairs adjacent aligned to amplicon reference sequence). 
##		Alignment to hg19 + NT amplicons + IS amplicons + CC amplicons
##
##Intended use:
##	Used to remove human, IS and CC reads, eliminate recombinant reads, unmappable reads.
## 	QC metrics: Count per amplicon of recombinants (NTRecomboCount.txt), mapq failures (mapqCount.txt), 
##		passing read (NTPassCount.txt) as separate output files, Complexity reads
## Program flow:
## read base change lookupTable, create base change hash table CHROM:POS [bad base], 
## 	LookupTable, cc are >3 contiquous lower case, dinucleotides will not use second base as BC position, the fix, skip a base in DN design.
##	For each read record, expand based on CIGAR.  Count & reject MAPQ failures.
##	CC extract  CC-region track unique and their replicates. 
##	If NT or IS count base change positions/recominbants then reject bad reads
##	Write QC to files
##
## Example script:
##bwa mem -v 1 -R $(echo $rg) -t 32 $ref  "${pi}/${fn}_R1_001.fastq.gz" "${pi}/${fn}_R2_001.fastq.gz" |\
## awk -f remRecombo.awk -v offspringCutoff=0.01 -v RC=1 -v mapq=1 -v qCutoff=0 -v gbc=1 -v outputIS=0 -v sampleName=${fn} Artic_v3_NT_IS_amplicons_basechange_new2.txt - |\
##        samtools sort -@ 16 -m 1G -O bam -o "${po}/${fn}.bam" -
##For Support: tmorrison@accuGenomics.com

BEGIN {
	poolCount=0
	ccRegion=0
	xs="!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
}
FNR==1{
	FNUM++
	if(FNUM==2){#No CC position should be in base change hash, first CC position is, remove first CC position
		for (key in ccPos){
			split(ccPos[key],ccRange,":")
			keyIS=key "-000-SNAQ-IS"
			keyNT=key "-000-SNAQ-NT"
			delete ISs[keyNT ":" ccRange[1]]
			delete ISs[keyIS ":" ccRange[1]]
			delete NTs[keyNT ":" ccRange[1]]
                	delete NTs[keyIS ":" ccRange[1]]
		}
	}	
}
FNUM==1{ #process lookup table, pick out sequential lower case REF as CC regions stored in ccPos
	if(NR==1 && ($1 != "NT_CHROM" || $2 != "NT_POS" || $3 != "NT_REF" || $4 != "IS_CHROM" || $5 != "IS_POS" || $6 != "IS_REF" )) {
		print "ERROR: NT-IS lookup file header incorrect" > "/dev/stderr"
		print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 > "/dev/stderr"
		exit 1
	}
	if($6 ~/[gatc]/) {
		if($4 ~/-SNAQ-CC$/) {
			if($5 == lastPos +1){
				#lower case bases are adjacent
				if(ccRegion == 0 && $1 ~ /-SNAQ-NT$/) {
					#first adjacent pair, start scan only on NT x CC 
					firstPos = lastPos
					firstBase = lastBase
					ccRegion = 1 #indicates CC scan is active
					lastChrom = $4
					split(lastChrom,temp,"-")
					lastAmp=temp[2] # used for CC fit distr lastAmp=temp[3]
				}
				lastBase=$6
				lastPos=$5
				next
			} else if(ccRegion) {
				#TRUE, just exited CC scan
				# CC region is defined as <flank-base><some # of degenerate bases><flank-base>, capture this in ccPos
				ccRegion=0
				temp1=lastChrom;sub("-001-SNAQ-CC","",temp1)
				ccPos[temp1] = firstPos ":" lastPos ":" toupper(firstBase) ":" toupper(lastBase) ":" lastAmp  #coordinates of CC
			}
		}
		lastPos = $5
		lastBase=$6
		ISs[$1 ":" $2] = toupper($3) #CHROM:POS = good base
		NTs[$1 ":" $2] = toupper($6) #CHROM:POS = bad base
		if($4 !~/-SNAQ-CC$/){#CC will not be checked for base change positions or recombinants.  CC region has internal checks
			ISs[$4 ":" $5] = toupper($6)
			NTs[$4 ":" $5] = toupper($3)
		}
	}
	next
}
!/^@/ {#expand sequence if CC or variant detected.
	if($3 !~/-SNAQ-/){#not relavant targeted sequence?
		if($3=="*"){
			unmappedCount++
			next
		} else {
			offTargetCount++
			next
		}
	}
	tmp=$10
	gsub("N","",tmp) #bwa occationally does not soft clip Ns which messes up the CIGAR logic.
	tmpq=$11
	cmp=$6
	n=patsplit(cmp,a,/[0-9]*[MSIDH]/) 
	pnt=0
	for(i=1;i<=n;i++){
		cd=substr(a[i],length(a[i]),1) 
		nm=substr(a[i],1,length(a[i])-1) 
		if(cd=="M" || cd=="=" || cd=="X"){
			pnt=pnt+nm
		}
		else if (cd=="D" || cd=="N"){
			tmp=substr(tmp,1,pnt) substr(xs,1,nm) substr(tmp,pnt+1,length(tmp)) 
			if (qCutoff) {tmpq=substr(tmpq,1,pnt) substr(xs,1,nm) substr(tmpq,pnt+1,length(tmpq))}
			pnt=pnt+nm 
		}
		else if (cd=="I"){
	                tmp=substr(tmp,1,pnt) substr(tmp,pnt+nm+1,length(tmp)-nm-pnt )
			if (qCutoff) {tmpq=substr(tmpq,1,pnt) substr(tmpq,pnt+nm+1,length(tmpq)-nm-pnt )}
		}	
	        else if (cd=="S"){
	                tmp=substr(tmp,1,pnt) substr(tmp,pnt+nm+1,length(tmp)-nm-pnt )
			if (qCutoff) {tmpq=substr(tmpq,1,pnt) substr(tmpq,pnt+nm+1,length(tmpq)-nm-pnt )} 
	        }
		else if (cd=="H" || cd=="P"){
		}
		else{
			print $1 " cigar Term " cd " not recognized" > "/dev/stderr"
			exit 1
		}
	}
	fragSize=length(tmp)
	if ($3 ~ /-SNAQ-CC$/) { # extract CC
		if(samOutput){print $0 >> (resultsPath "-CC.sam")}
		temp1=$3;split(temp1,arr,"-")
		split(ccPos[arr[1]"-"arr[2]],ccRange,":") #first POS:last POS:first base:last base:lastAmp?
		if($4 <= ccRange[1] && $4 + fragSize >= ccRange[2] && !($1 in CCc2)){ #CCc2 tracks read index, no double counting
			t2 = ccRange[1] - $4 + 1
			CCc2[$1] = 1
			t1 = substr(tmp,t2, ccRange[2] - ccRange[1] + 1)
			pat = "^" ccRange[3] "[AGTC]{8}" ccRange[4]
			if(t1 ~ pat ) {
				complexityCount[ccRange[5] "\t" t1]++
			} else {
				complexityCount[ccRange[5] "b\t" t1]++
			}
		}
	} else {#detect recombinants and count basechange positions
		recomboFound=0;baseChange=0
		qPass=1 #if qCutoff=0, this will bipass qscore test
		n=split(tmp,a,"")
		if (qCutoff) {split(tmpq,aq,"")} #only needed if qScore test is implemented
		for (i=1;i<=n;i++){
			if (qCutoff) { 
				if (aq[i] >= qCutoff) {
					qPass=1
				} else {
					qPass=0
				} 
			}
			if ($3 ":" $4+i-1 in NTs && qPass){ #Basechange position with passing qscore otherwise not interested in POS
				if (NTs[$3 ":" $4+i-1] == a[i]){ #base match indicates recombination
					recomboFound++
				} 
				if (ISs[$3 ":" $4+i-1] == a[i]){
					baseChange++
				}
			}
		}
		readPass1 = recomboFound < RC && $7=="=" #Instant fail: read pair will fail either read has recombo, chimera, 
		readPass2 = ($5 >= mapq) && fragSize > minFragSize && (baseChange >= gbc ) #Fail only if singl or pair are both faile
		##for debugging purposes
		#if ($1=="M04993:95:000000000-J6C9M:1:1104:16388:19926"){
		#	print $0 "\n" baseChange "\t" recomboFound "\t" lastQuery "\t" lastGoodRecord > "/dev/stderr"	
		#	}
		if (single){
	                readPass1 = recomboFound < RC #Instant fail: read pair will fail either read has recombo, chimera,
        	        readPass2 = ($5 >= mapq) && (baseChange >= gbc ) #Fail only if singl or pair are both faile
			
			if(readPass1 && readPass2) {
                        	if(samOutput){print $0 >> (resultsPath "-pass.sam")}
                        	if (outputIS || $3 ~/SNAQ-NT$/) {
                                	print $0
                        	}	
                        	NTPassCount[$3]++
                		split($12,temp,":")
				if(temp[1]=="NM"){
                        		nmCount[$3]+=temp[3]
                		}else{
                        		nmCount[$3]+=0 #some bwa mem sequence rows don't NM
                		}
                        	baseCount[$3]+=fragSize
                	}else if (readPass1==0){
                        	NTRecomboCount[$3]++
                        	if(samOutput) {print $0 >> (resultsPath "-recombo.sam")} #for troubleshooting
                	}else {
                        	mapqCount[$3]++
                        	if(samOutput) {print $0 >> (resultsPath "-mapq.sam")} #for troubleshooting
                	}
		}else {
	       		if (!lastQuery) {
			#don't go through keep/reject logic on first read into script
			} else if($1==lastQuery){#current read had same cluster as last read (i.e., read pair)
				paired=1
				if (lastReadPass1 && readPass1 && (lastReadPass2 || readPass2)) {
                	        	readPass3=1 #current read pair pass
				} else if (!lastReadPass1 || !readPass1) {#recombination read pair reject
					readPass3=2
                       		} else {#mapq readpair reject
					readPass3=3
				}
			} else if (!paired){#not paired reads, so read stands on own merits
				if(!lastReadPass1){
					readPass3=2
				}else if(!lastReadPass2){
					readPass3=0
				}else {
					readPass3=1
				}
			}	
			if (readPass3==1){#now generate outcome from read analysis
	        	        if(samOutput){print lastGoodRecord >> (resultsPath "-pass.sam")}
				if (outputIS || lastChrom ~/SNAQ-NT$/) {
        	                	print lastGoodRecord
                        	}
         	                NTPassCount[lastChrom]++
                	        nmCount[lastChrom]+=lastNMValue
                        	baseCount[lastChrom]+=lastLength
			}else if (readPass3==2){
        	                NTRecomboCount[lastChrom]++
				if(samOutput) {print lastGoodRecord >> (resultsPath "-recombo.sam")} #for troubleshooting
			}else if (readPass3==3){
				mapqCount[lastChrom]++
				if(samOutput) {print lastGoodRecord >> (resultsPath "-mapq.sam")} #for troubleshooting
			}
			split($12,temp,":")
			if(temp[1]=="NM"){
				lastNMValue=temp[3]
			}else{
				lastNMValue=0 #some bwa mem sequence rows don't NM 
			}
			lastChrom=$3
			lastQuery=$1
			lastLength=fragSize
			lastGoodRecord=$0
			lastReadPass2=readPass2
			lastReadPass1=readPass1
		}
	}
}
/^@/ {	
	if(samOutput) {
		print $0 > (resultsPath "-pass.sam")
		print $0 > (resultsPath "-recombo.sam")
	       	print $0 > (resultsPath "-mapq.sam")
		print $0 > (resultsPath "-CC.sam") 
	}#for troubleshooing
}

END	{
	for (i in NTPassCount){
		print sampleName "\t" i "\t" NTPassCount[i] >> (resultsPath "-PassCount.txt")
	}
	for (i in NTRecomboCount){
		print sampleName "\t" i "\t" NTRecomboCount[i] >> (resultsPath "-BadCount.txt")
	}

        for (i in mapqCount){
                print sampleName "\t" i "\t" mapqCount[i] >> (resultsPath "-mapqCount.txt")
        }
        for (i in complexityCount){
	print sampleName "\t" i "\t" complexityCount[i] >> (resultsPath "-ComplexityCount.txt")
        }
        for (i in nmCount){
                print sampleName "\t" i "\t" nmCount[i] >> (resultsPath "-NMCount.txt")
        }
        for (i in baseCount){
                print sampleName "\t" i "\t" baseCount[i] >> (resultsPath "-BaseCount.txt")
        }
	print sampleName "\t" offTargetCount >> (resultsPath "-offTargetCount.txt")
	print sampleName "\t" unmappedCount >> (resultsPath "-unmappedCount.txt")

} 
