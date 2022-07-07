#CombineThreads uses the SNAQ Analysis text files created by the SNAQ-SEQ analysis of
# Covid-19 sequencing data spiked with SNAQ IS and creates a flat file of the analysis results.
#fed commands line depicted below

#/NGS/USAF/sbir/script 
# -f1 /NGS/USAF/220307/MEfastq/28-CV22-07-085_S332_ME_L001_R1_001.fastq.gz 
# -f2 /NGS/USAF/220307/MEfastq/28-CV22-07-085_S332_ME_L001_R2_001.fastq.gz 
# -o /NGS/USAF/220307/newfastq -r /NGS/USAF/REFS/hg19-MID121.fasta 
# -bc /NGS/USAF/REFS/MID121-NT-IS-CC-amplicon-basechange.txt 
# -t 32 
# -bo 1 
# -cco 0.01 
# -mf -1 
# -rc 1 
# -mq -1 
# -mbc 1 
# -oi 0 
# -qs -1 
# -cc 3000 
# -is 3000 
# -nf /NGS/USAF/sbir/normalizer-MidnightV1.txt

args = commandArgs(trailingOnly=TRUE)
commandLine=args[1]

separator=","
#headerString="FASTQ_File_Name,FASTQ_File_Date,SNAQ-SEQ_Analysis_Date,SNAQ-SEQ_Command_Line,Viral_Load,Unique_CC_Count,Fraction_CC_PASS,%CC,Median_CC_Duplication_Rate,Median_Recombination_Rate_IS,Median_Recombination_Rate_NT,Median_NT_Reads_Per_Amplicon,Median_IS_Reads_Per_Amplicon,Median_NT_Coverage,Median_NT_NM,Median_IS_NM,Median_NT_Base_Count,Median_IS_Base_Count,Median_NT_Bad_Reads,Median_IS_Bad_Reads,Unmapped_Read_Count,Off-Target_Read_Count"
headerString="FASTQ_File_Name,FASTQ_File_Date,SNAQ-SEQ_Analysis_Date,SNAQ-SEQ_Command_Line,Viral_Load,Median_Recombination_Rate_IS,Median_Recombination_Rate_NT,Median_NT_Reads_Per_Amplicon,Median_IS_Reads_Per_Amplicon,Median_NT_Coverage,Median_NT_NM,Median_IS_NM,Median_NT_Base_Count,Median_IS_Base_Count,Median_NT_Bad_Reads,Median_IS_Bad_Reads,Unmapped_Read_Count,Off-Target_Read_Count"

#extract FASTQ R1 file path as common key for all data files
scratchDir=sub("^.+\\s-sd\\s(\\S+).*$","\\1",commandLine)
singleTable=data.frame(commandLine=commandLine)
singleTable$FASTQ_File_Name=sub("^.+\\s-f1\\s(\\S+).*$","\\1",commandLine)
#Create fastq path for CLI
temp=sub("^.+\\s-f2\\s(\\S+).*$","\\1",commandLine)
if (length(temp)){
	singleTable$path=paste0(singleTable$FASTQ_File_Name,";",temp)
}else{
singleTable$path="singleTable$FASTQ_File_Name"
}

#extract file modified input passed in the "simulated command line" input arg
singleTable$creationDate=as.character(sub("^(.+)\\..*$","\\1",sub("_"," ",sub("^.+\\s-md\\s(\\S*)\\s.*$","\\1",commandLine))))

#extract analysis date from the input command line
singleTable$analysisDate=as.character(sub("^(.+)\\..*$","\\1",format(Sys.time(),format="%Y-%m-%d %H:%M:%S")))

#extract the file path of where the cli will be appened to
outputFile=sub("^.+\\s-of\\s(\\S+).*$","\\1",commandLine)

#import normalizer file, also used to ensure all amplicon positions are represented in dataframes
normalizerPath=sub("^.+\\s-nf\\s(\\S+).*$","\\1",commandLine)
normalizer=read.table(file=normalizerPath,header = T,sep="\t",stringsAsFactors = F)
colnames(normalizer)=c("ampliconName","normalizer")
ccData=data.frame(ampliconName=normalizer$ampliconName[grepl("^~",normalizer$ampliconName)],stringsAsFactors=F)
ccData$ampliconName=sapply(strsplit(ccData$ampliconName,"-"),'[[',2)
normalizer$ampliconName=gsub('^~','',normalizer$ampliconName)
normalizer$ampNum= gsub("Amp","", sapply(strsplit(normalizer$ampliconName,"-"),"[",2))

#aggregate passing NT and IS amplicon counts threads
fileList=list.files(scratchDir,pattern="-PassCount.txt$")
if (length(fileList)==0){
	print("**** No passing reads detected, exiting ****")
	quit(status=1)
}else{
	temp=do.call("rbind",(lapply(paste0(scratchDir,"/",fileList), function(x)read.table(file=x,header = F,sep="\t",stringsAsFactors = F))))
	colnames(temp)=c("FASTQ_File_Name","ampliconName","passCount")
	temp1=aggregate(passCount~FASTQ_File_Name+ampliconName,data=temp,sum)
	temp2=normalizer[,c("ampliconName","ampNum")]
#ensure every amplicon x IS or NT possible
	temp3=temp2
	temp2$ampliconName=paste0(temp2$ampliconName,"-000-SNAQ-NT")
        temp3$ampliconName=paste0(temp3$ampliconName,"-000-SNAQ-IS")
	temp4=rbind(temp2,temp3)
	dataTable=merge(temp4,temp1,by="ampliconName",all.x=T)
	dataTable$FASTQ_File_Name[is.na(dataTable$FASTQ_File_Name)]=singleTable$FASTQ_File_Name
	dataTable$passCount[is.na(dataTable$passCount)]=0
}

fileList=list.files(scratchDir,pattern="-BadCount.txt$")
if (length(fileList)==0){
	dataTable$badCount=0
}else{
	temp=do.call("rbind",(lapply(paste0(scratchDir,"/",fileList), function(x)read.table(file=x,header = F,sep="\t",stringsAsFactors = F))))
	colnames(temp)=c("FASTQ_File_Name","ampliconName","badCount")
	temp1=aggregate(badCount~FASTQ_File_Name+ampliconName,data=temp,sum)
	dataTable=merge(dataTable,temp1,by=c("FASTQ_File_Name","ampliconName"),all.x=T)
}

fileList=list.files(scratchDir,pattern="-BaseCount.txt$")
if (length(fileList)==0){
	dataTable$baseCount=0
}else{
	temp=do.call("rbind",(lapply(paste0(scratchDir,"/",fileList), function(x)read.table(file=x,header = F,sep="\t",stringsAsFactors = F))))
	colnames(temp)=c("FASTQ_File_Name","ampliconName","baseCount")
	temp1=aggregate(baseCount~FASTQ_File_Name+ampliconName,data=temp,sum)
	dataTable=merge(dataTable,temp1,by=c("FASTQ_File_Name","ampliconName"),all.x=T)
}

fileList=list.files(scratchDir,pattern="-mapqCount.txt$")
if (length(fileList)==0){
	dataTable$mapqCount=0
}else{
	temp=do.call("rbind",(lapply(paste0(scratchDir,"/",fileList), function(x)read.table(file=x,header = F,sep="\t",stringsAsFactors = F))))	
	colnames(temp)=c("FASTQ_File_Name","ampliconName","mapqCount")
	temp1=aggregate(mapqCount~FASTQ_File_Name+ampliconName,data=temp,sum)
	dataTable=merge(dataTable,temp1,by=c("FASTQ_File_Name","ampliconName"),all.x=T)
}

fileList=list.files(scratchDir,pattern="-NMCount.txt$")
if (length(fileList)==0){
	dataTable$NMCount=0
}else{
	temp=do.call("rbind",(lapply(paste0(scratchDir,"/",fileList), function(x)read.table(file=x,header = F,sep="\t",stringsAsFactors = F))))
	colnames(temp)=c("FASTQ_File_Name","ampliconName","NMCount")
	temp1=aggregate(NMCount~FASTQ_File_Name+ampliconName,data=temp,sum)
	dataTable=merge(dataTable,temp1,by=c("FASTQ_File_Name","ampliconName"),all.x=T)
}

#collect single calculation fields
modifiedDate=sub("^.+\\s-md\\s([0-9]+{4}-[0-9]+{2}-[0-9]+{2}\\s[0-9]+{2}:[0-9]+{2}:[0-9]+{2}).*$","\\1",commandLine) 

fileList=list.files(scratchDir,pattern="-offTargetCount.txt$")
if (length(fileList)==0){
	singleTable$offTargetCount=0
}else{
	temp=do.call("rbind",(lapply(paste0(scratchDir,"/",fileList), function(x)read.table(file=x,header = F,sep="\t",stringsAsFactors = F))))
	singleTable$offTargetCount=sum(temp$V2)
}

fileList=list.files(scratchDir,pattern="-unmappedCount.txt$")
if (length(fileList)==0){
	singleTable$unmappedCount=0
}else{
	temp=do.call("rbind",(lapply(paste0(scratchDir,"/",fileList), function(x)read.table(file=x,header = F,sep="\t",stringsAsFactors = F))))
	singleTable$unmappedCount=sum(temp$V2)
}

#collect CC and filter out offspring
ccData$FASTQ_File_Name=unique(dataTable$FASTQ_File_Name)
cc=as.integer(sub("^.+\\s-cc\\s([0-9]*)\\s.*$","\\1",commandLine))
offSpringFraction=as.numeric(sub("^.+\\s-cco\\s([0-9]*\\.[0-9]*)\\s.*$","\\1",commandLine))
fileList=list.files(scratchDir,pattern="-ComplexityCount.txt$")
if (length(fileList)==0){
    ccData$CCcount.x=0
	ccData$CCTotalcount=0
	ccData$meanCC=0
}else{
    temp=do.call("rbind",(lapply(paste0(scratchDir,"/",fileList), function(x)read.table(file=x,header = F,sep="\t",stringsAsFactors = F))))
	colnames(temp)=c("FASTQ_File_Name","ampliconName","seq","CCcount")
	temp1=aggregate(CCcount~FASTQ_File_Name+ampliconName+seq,data=temp,sum)
	temp2=aggregate(CCcount~FASTQ_File_Name+ampliconName,data=temp1,max)
	temp1=merge(temp1,temp2,by=c("FASTQ_File_Name","ampliconName")) #merge the max CC for each CC amplicon
    temp1=temp1[temp1$CCcount.x>offSpringFraction*temp1$CCcount.y,] #remove low count CC sequences (offspring)
	totalCC=setNames(aggregate(CCcount.x~FASTQ_File_Name+gsub("b","",temp1$ampliconName),data=temp1,length),c("FASTQ_File_Name","ampliconName","CCTotalcount")) #sum different CC sequences, both good and bad, by amplicon
ccData=merge(ccData,totalCC,by=c("FASTQ_File_Name","ampliconName"),all.x=T)
    if (nrow(temp1[!grepl(".+[0-9]{3}b$",temp1$ampliconName),])==0){ #may end up with only b type amplicons, so no CCcount or meanCC
        ccData$CCcount.x=0
		ccData$meanCC=0	
	}else{
        uniqueCC=aggregate(CCcount.x~FASTQ_File_Name+ampliconName,data=temp1[!grepl(".+[0-9]{3}b$",temp1$ampliconName),],length)
		meanCC=setNames(aggregate(CCcount.x~FASTQ_File_Name+ampliconName,data=temp1[!grepl(".+[0-9]{3}b$",temp1$ampliconName),],mean),c("FASTQ_File_Name","ampliconName","meanCC"))
    ccData=merge(ccData,uniqueCC,by=c("FASTQ_File_Name","ampliconName"),all.x=T)
		ccData=merge(ccData,meanCC,by=c("FASTQ_File_Name","ampliconName"),all.x=T)
	}
    ccData$CCTotalcount[is.na(ccData$CCTotalcount)]=0
    ccData$CCcount.x[is.na(ccData$CCcount.x)]=0
    ccData$meanCC[is.na(ccData$meanCC)]=0
}
#Add simple IS or NT column
dataTable$type= sapply(strsplit(dataTable$ampliconName,"-"),"[",5)

#amplicon Abundance
IS=as.integer(sub("^.+\\s-is\\s([0-9]*)\\s.*$","\\1",singleTable$commandLine))  #collect IS spike-in abundance
abundanceTable=merge(dataTable[dataTable$type=="NT",c("FASTQ_File_Name","ampNum","passCount")],
           dataTable[dataTable$type=="IS",c("FASTQ_File_Name","ampNum","passCount")],by=c("FASTQ_File_Name","ampNum"))
abundanceTable=merge(abundanceTable,normalizer[,c("ampNum","normalizer")],by="ampNum",all.x=T)
abundanceTable$abundance=abundanceTable$passCount.x/abundanceTable$passCount.y*IS*abundanceTable$normalizer
abundanceTable$abundance[!is.finite(abundanceTable$abundance)]=NA
if (nrow(abundanceTable[!is.na(abundanceTable$abundance),])==0){
	singleTable$viralLoad=0
}else{
	viralLoad=setNames(aggregate(abundance~FASTQ_File_Name,data=abundanceTable,median),c("FASTQ_File_Name","viralLoad"))
	singleTable=merge(singleTable,viralLoad,by="FASTQ_File_Name",all.x = T)
}
if (nrow(abundanceTable[!is.na(abundanceTable$passCount.x),])==0){
	singleTable$medNTCount=0
}else{
	temp=setNames(aggregate(passCount.x~FASTQ_File_Name,data=abundanceTable,median),c("FASTQ_File_Name","medNTCount"))
	singleTable=merge(singleTable,temp,by="FASTQ_File_Name",all.x = T)
}
if (nrow(abundanceTable[!is.na(abundanceTable$passCount.y),])==0){
	singleTable$medISCount=0
}else{
	temp=setNames(aggregate(passCount.y~FASTQ_File_Name,data=abundanceTable,median),c("FASTQ_File_Name","medISCount"))
	singleTable=merge(singleTable,temp,by="FASTQ_File_Name",all.x = T)
}
if (nrow(dataTable[dataTable$type=="NT" & !is.na(dataTable$NMCount),])==0){
         singleTable$NTNMCount=0
}else{
	temp=setNames(aggregate(NMCount~FASTQ_File_Name,data=dataTable[dataTable$type=="NT",],median),c("FASTQ_File_Name","NTNMCount"))
	singleTable=merge(singleTable,temp,by="FASTQ_File_Name",all.x = T)
}
if (nrow(dataTable[dataTable$type=="IS" & !is.na(dataTable$NMCount),])==0){
         singleTable$ISNMCount=0
}else{
	temp=setNames(aggregate(NMCount~FASTQ_File_Name,data=dataTable[dataTable$type=="IS",],median),c("FASTQ_File_Name","ISNMCount"))
	singleTable=merge(singleTable,temp,by="FASTQ_File_Name",all.x = T)
}

#median base count
if (nrow(dataTable[dataTable$type=="NT" & !is.na(dataTable$baseCount),])==0){
         singleTable$NTBaseCount=0
}else{
	temp=setNames(aggregate(baseCount~FASTQ_File_Name,data=dataTable[dataTable$type=="NT",],median),c("FASTQ_File_Name","NTBaseCount"))
	singleTable=merge(singleTable,temp,by="FASTQ_File_Name",all.x = T)
}
if (nrow(dataTable[dataTable$type=="IS" & !is.na(dataTable$baseCount),])==0){
         singleTable$ISBaseCount=0
}else{
	temp=setNames(aggregate(baseCount~FASTQ_File_Name,data=dataTable[dataTable$type=="IS",],median),c("FASTQ_File_Name","ISBaseCount"))
	singleTable=merge(singleTable,temp,by="FASTQ_File_Name",all.x = T)
}

#bad Read Rate per amplicon
dataTable$nmRate=dataTable$NMCount/dataTable$baseCount
if (nrow(dataTable[dataTable$type=="IS" & !is.na(dataTable$nmRate),])==0){
	 singleTable$ISNMRate=0
}else{
	temp=setNames(aggregate(nmRate~FASTQ_File_Name,data=dataTable[dataTable$type=="IS",],median),c("FASTQ_File_Name","ISNMRate"))
	singleTable=merge(singleTable,temp,by="FASTQ_File_Name",all.x = T)
}
if (nrow(dataTable[dataTable$type=="NT" & !is.na(dataTable$nmRate),])==0){
	singleTable$NTNMRate=0
}else{
	temp=setNames(aggregate(nmRate~FASTQ_File_Name,data=dataTable[dataTable$type=="NT",],median),c("FASTQ_File_Name","NTNMRate"))
	singleTable=merge(singleTable,temp,by="FASTQ_File_Name",all.x = T)
}
# CC yield
ccData$ccYield=ccData$CCcount.x/cc

#make sure all fields are filled out
ampliconOutput=data.frame(ampNum=sort(unique(dataTable$ampNum)))
ampliconOutput=setNames(merge(ampliconOutput,unique(dataTable$FASTQ_File_Name),all=T),c("ampNum","FASTQ_File_Name"))
ampliconOutput=merge(ampliconOutput,dataTable[dataTable$type=="NT", c("ampNum","FASTQ_File_Name","passCount","badCount","NMCount","baseCount","mapqCount")],by=c("ampNum","FASTQ_File_Name"),all.x = T)
ampliconOutput=merge(ampliconOutput,dataTable[dataTable$type=="IS", c("ampNum","FASTQ_File_Name","passCount","badCount","NMCount","baseCount","mapqCount")],by=c("ampNum","FASTQ_File_Name"),all.x = T)
ampliconOutput=merge(ampliconOutput,abundanceTable[ ,c("ampNum","FASTQ_File_Name","abundance")],by=c("ampNum","FASTQ_File_Name"),all.x = T)

##Coverage calculation, assume CC amp positions matches primer pool pattern, e.g., CC47, CC48, CC49 exists -> amp 1,4,7...belong to CC47

temp1=gsub("Amp","",ccData$ampliconName)
if(length(temp1)==0){
    ampliconOutput$ampliconCoverage=NA
}else{
    ampliconOutput$NTtotCounts=(ampliconOutput$passCount.x +
                (ampliconOutput$badCount.x + ampliconOutput$badCount.y)/2) #to make mathmatically compatible with CC, use all pass+recombo
    for (j in seq(1,length(temp1),1)){
        ur=ampliconOutput$NTtotCounts[ampliconOutput$ampNum==temp1[j]]/
             ccData$CCcount.x[ccData$ampliconName==paste0("Amp",temp1[j])] /
             ccData$meanCC[ccData$ampliconName==paste0("Amp",temp1[j])]
    
        i=seq(j,length(ampliconOutput$ampNum),by=length(temp1)) #step through each amplicon pool assumes CC in order.
        ampliconOutput$NTpass[i]=ampliconOutput$NTtotCounts[i] / ur
        ampliconOutput$dupl[i]=ampliconOutput$NTpass[i] /( ccData$ccYield[j] * singleTable$viralLoad) #%CC
        ampliconOutput$dupl[ampliconOutput$dupl<1]=1
        ampliconOutput$cCov[i]=ampliconOutput$NTpass[i]/ampliconOutput$dupl[i]
        ampliconOutput$adj1[i]=ampliconOutput$passCount.x[i]/
            ampliconOutput$passCount.y[i] /
            median(ampliconOutput$passCount.x[i]/ampliconOutput$passCount.y[i]) 
        ampliconOutput$ampliconCoverage[i]=ampliconOutput$cCov[i] /normalizer$normalizer[i] /ampliconOutput$adj1[i] 
    }
}
##new calculation
# ur= IS47.pass + (IS47.bad + NT47.bad) /2 / unique_CC / duplication #universal reads per uniq template (replaceable with ampli size /frag size varition
# for each NT.pass + (IS.bad + NT.bad)/2  / ur   #templates per amplicon
# for each NTur / Viral load, if <1.0 set equal to 1.0 #duplications per amplicon
# crude coverage = NTur/duplication # can incorporate poisson estimate for more accuracy duplicate = 1.0 means actual loss could be greater
# NTcor = NT.pass/IS.pass for each amplicon / median # creats a normalizer for NT yields centered on 1.0
# ampliconOutput$ampliconCoverage= NTcv * normalizer$normalizer * NTcor #this corrects for IS yield differences & NT PCR efficiency differences

#median recombination rate
dataTable$medRecRate=dataTable$badCount/(dataTable$badCount+dataTable$passCount+dataTable$mapqCount)
if(nrow(dataTable[dataTable$type=="NT" & !is.na(dataTable$medRecRate),])==0){
	singleTable$NTrecombinantRate=0
}else{
	temp=setNames(aggregate(medRecRate~FASTQ_File_Name,data=dataTable[dataTable$type=="NT",],median),c("FASTQ_File_Name","NTrecombinantRate"))
	singleTable=merge(singleTable,temp,by="FASTQ_File_Name",all.x = T)
}
if(nrow(dataTable[dataTable$type=="IS" & !is.na(dataTable$medRecRate),])==0){
	singleTable$ISrecombinantRate=0
}else{
	temp=setNames(aggregate(medRecRate~FASTQ_File_Name,data=dataTable[dataTable$type=="IS",],median),c("FASTQ_File_Name","ISrecombinantRate"))
	singleTable=merge(singleTable,temp,by="FASTQ_File_Name",all.x = T)
}
if (! file.exists(outputFile)){
	temp2=nrow(ampliconOutput)
	headerString=paste0(headerString,
			    paste0(sprintf(",NR%03d",seq(1:temp2)),collapse=""),
                paste0(sprintf(",IR%03d",seq(1:temp2)),collapse=""),
			    paste0(sprintf(",AA%03d",seq(1:temp2)),collapse=""),
				paste0(sprintf(",CV%03d",seq(1:temp2)),collapse=""),
				paste0(sprintf(",NX%03d",seq(1:temp2)),collapse=""),
				paste0(sprintf(",IX%03d",seq(1:temp2)),collapse=""),
				paste0(sprintf(",NN%03d",seq(1:temp2)),collapse=""),
				paste0(sprintf(",IN%03d",seq(1:temp2)),collapse=""),
				paste0(sprintf(",NB%03d",seq(1:temp2)),collapse=""),
				paste0(sprintf(",IB%03d",seq(1:temp2)),collapse=""),
				paste0(sprintf(",NBA%03d",seq(1:temp2)),collapse=""),
				paste0(sprintf(",IBA%03d",seq(1:temp2)),collapse=""),
                paste0(",Unique_CC_Count-",unique(ccData$ampliconName),collapse = ""),
                paste0(",Fraction_CC_PASS-",unique(ccData$ampliconName),collapse = ""),
                paste0(",%CC-",unique(ccData$ampliconName),collapse = ""),
                paste0(",Mean_CC_Duplication_Rate-",unique(ccData$ampliconName),collapse = ""),
                collapse="")
	write.table(headerString,file=outputFile,append=T,quote = F, col.names = F, row.names = F)
}
#sort amplicon output for output
ampliconOutput=ampliconOutput[order(ampliconOutput$ampNum),]
#create output table, create by appending
singleTable$output=paste(singleTable$path,# FASTQ_File_Name
                         singleTable$creationDate,# FASTQ_File_Date
                         singleTable$analysisDate, 
                         singleTable$commandLine,# SNAQ-SEQ_Command_Line
                         singleTable$viralLoad,# Viral_Load
#                         singleTable$CCcount.x,# Unique_CC_Count
#                         singleTable$CCcount.x/singleTable$CCTotalcount,# Fraction_CC_PASS
#                         singleTable$ccYield,# %CC
#                         singleTable$meanCC,# Median_CC_Duplication_Rate
                         singleTable$ISrecombinantRate,# Median_Recombination_Rate_IS
                         singleTable$NTrecombinantRate,# Median_Recombination_Rate_NT
                         singleTable$medNTCount,# Median_NT_Reads_Per_Amplicon
                         singleTable$medISCount,# Median_IS_Reads_Per_Amplicon
                         median(ampliconOutput$ampliconCoverage),
                         singleTable$NTNMCount, # Median_NT_NM
                         singleTable$ISNMCount ,# Median_IS_NM
                         singleTable$NTBaseCount,# Median_NT_Base_Count
                         singleTable$ISBaseCount,# Median_IS_Base_Count
                         singleTable$NTNMRate,# Median_NT_Bad_Reads
                         singleTable$ISNMRate,# Median_IS_Bad_Reads
                         singleTable$unmappedCount,# Unmapped_Read_Count
                         singleTable$offTargetCount,# Off-Target_Read_Count
                         paste(ampliconOutput$passCount.x,collapse = ","), # NR001 PaSS NT Reads
                         paste(ampliconOutput$passCount.y,collapse = ","), # IR001 PASS IS Reads
                         paste(ampliconOutput$abundance,collapse = ","), # AA029 NT Amplicon Abundance
                         paste(ampliconOutput$ampliconCoverage,collapse = ","), # CV001 NT Genomic Coverage
                         paste(ampliconOutput$badCount.x,collapse = ","), # NX001 NT Recombinant Read Count
                         paste(ampliconOutput$badCount.y,collapse = ","), # IX001 IS Recombinante Read count
                         paste(ampliconOutput$NMCount.x,collapse = ","), # NN001 NT NM count by amplicon
                         paste(ampliconOutput$NMCount.y,collapse = ","), # IN001 IS NM Count by amplicon
                         paste(ampliconOutput$baseCount.x,collapse = ","), # NB001 NT Base Count by amplicon
                         paste(ampliconOutput$baseCount.y,collapse = ","), # IB001 IS Base Count by amplicon
                         paste( ampliconOutput$mapqCount.x,collapse = ","), # NBA001 NT mapq counts by amplicon
                         paste(ampliconOutput$mapqCount.y,collapse = ","), # NBA001 IS mapq counts by amplicon
                         paste(ccData$CCcount.x,collapse = ","), #Unique_CC_Count
                         paste(ccData$CCcount.x/ccData$CCTotalcount,collapse = ","), #Fraction CC PASS
                         paste( ccData$ccYield,collapse = ","), #%CC

                         paste(ccData$meanCC,collapse = ","), #mean CC dupl
                         sep=separator)

write.table(singleTable$output,file=outputFile,append=T,quote = F, col.names = F, row.names = F)

