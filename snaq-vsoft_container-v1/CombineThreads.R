#!/usr/bin/env Rscript
#
# author: "David R. Lorenz"
#
# Usage: CombineThreads.R -inputPath -outputPath -normfactorsPath -offSpringFraction
#
# Intended Use: The following script reads SNAQ-Vsoft aggregated count data, fastq file summary, and run 
# parameter files. Amplicon counts are merged, summary and QC statistics are calculated, and values are
# exported to .csv file.
#
# Program flow: File import with cleaning -> data summation by sample and amplicon and merging ->
# calculation of summary statistics. Missing (NA) values are imputed with zeros.
# 
# Example:
#   CombineThreads.R -/home/input/ -home/output/ -home/data/normalization/ -offSpringFraction

myargs = commandArgs(trailingOnly=TRUE)

path = myargs[1]
path2 = myargs[2]
path3 = myargs[3] #/home/data/normalization
offSpringFraction = myargs[4]

offSpringFraction <- as.numeric(gsub("^.*=", "", offSpringFraction))

separator=","


## file handling
# load sample table (fastq files)
singleTable <- read.table(file=file.path(path,"fastqCreationDate.txt"),
                          header=F, sep="\t",stringsAsFactors = F)
colnames(singleTable) <- c("FASTQ_File_Name","creationDate","path")

# load amplicon normalization file
#   check if normalization file has column names, use "CHROM"\t"NORMALIZER
#   if absent/something else
norm <- read.table(file=file.path(path3,"amplicon_normalization.txt"),
                   header = F, sep="\t", stringsAsFactors=F, as.is=T, 
                   comment.char="", quote="")

if (!(grepl("Amp", norm[1,1]))) {  norm <- norm[-1,]  }
names(norm) <- c("CHROM", "NORMALIZER")
norm$NORMALIZER <- as.numeric(norm$NORMALIZER)

# define sample - amplicon combinations for NT and IS reads
#   ensuring normalization file has no duplicates for -NT/-IS
samp_amp <- expand.grid(
    singleTable$FASTQ_File_Name,
    unique(c(norm$CHROM, gsub("-NT$", "-IS", norm$CHROM))), 
    c("NT", "IS"),
    stringsAsFactors = F)
names(samp_amp) <- c("FASTQ_File_Name", "ampNum", "type")
samp_amp$ampNum <- 
    gsub("Amp","", sapply(strsplit(samp_amp$ampNum,"-"),"[",2))

# define file column names 
counts_colnames <- list(
    BadCount=c("FASTQ_File_Name","amplconName","badCount"),
    BaseCount=c("FASTQ_File_Name","amplconName","baseCount"),
    ComplexityCount=c("FASTQ_File_Name","amplconName","seq","CCcount"),
    NMCount=c("FASTQ_File_Name","amplconName","NMCount"),
    PassCount=c("FASTQ_File_Name","amplconName","passCount"),
    mapqCount=c("FASTQ_File_Name","amplconName","mapqCount"),
    offTargetCount=c("FASTQ_File_Name","offTargetCount"),
    unmappedCount=c("FASTQ_File_Name","unmappedCount"))


## function to load and clean counts - sample-amplicon data tables 
f_fh <- function(fh, in_path, col_names) {

    df <- data.frame()

    if (file.exists(paste0(in_path, "/", fh)) &&
            file.size(file.path(in_path, fh))==0) {  # file w/ 0 bytes
        df <- as.data.frame(matrix(0, ncol=length(col_names), nrow=1))
        names(df) <- col_names
     } else if (file.exists(paste0(in_path, "/", fh))) {  # file with data
        df <- read.table(file=file.path(in_path, fh), 
            header=F, sep="\t", stringsAsFactors=F, as.is=T, comment.char="", 
            quote="")
        names(df) <- col_names
     } else {
        df <- as.data.frame(matrix(0, ncol=length(col_names), nrow=1))
        names(df) <- col_names
    }
    
    # remove blank amplconName
    if(any(names(df)=='amplconName')) { 
        df <- subset(df, amplconName != "")
    }
  
    # impute NA values with 0s
    df[[grep("count", names(df), ignore.case=T, value=T)]] <-
        ifelse(is.na(df[[grep("count", names(df), ignore.case=T, value=T)]]),
               0,
               df[[grep("count", names(df), ignore.case=T, value=T)]])
    
   
    return(df)
}


## create dataTable with successive merges
# PassCount
temp <- f_fh("PassCount.txt", path, unlist(counts_colnames$PassCount))

if(all(temp[1,]==0)) {  # no passCount data
    dataTable <- samp_amp
    dataTable$passCount <- 0
} else {
    dataTable <- 
        aggregate(passCount ~ FASTQ_File_Name + amplconName, data=temp, sum)
    dataTable$ampNum <- 
        gsub("Amp","", sapply(strsplit(dataTable$amplconName,"-"),"[",2))
    dataTable$type <- sapply(strsplit(dataTable$amplconName,"-"),"[",5)
    dataTable <- subset(dataTable, select=-amplconName)
    dataTable <- 
        merge(samp_amp, dataTable,
              by=c("FASTQ_File_Name", "ampNum", "type"), all.x=T)
}

# BadCount
temp <- f_fh("BadCount.txt", path, unlist(counts_colnames$BadCount))

if(all(temp[1,]==0)) {  # no badCount data
    dataTable$badCount <- 0
} else {
    temp <- 
        aggregate(badCount ~ FASTQ_File_Name + amplconName, data=temp, sum)
    temp$ampNum <- 
        gsub("Amp","", sapply(strsplit(temp$amplconName,"-"),"[",2))
    temp$type <- sapply(strsplit(temp$amplconName,"-"),"[",5)
    temp <- subset(temp, select=-amplconName)
    dataTable <- 
        merge(dataTable, temp,
              by=c("FASTQ_File_Name", "ampNum", "type"), all.x=T)
}

# BaseCount
temp <- f_fh("BaseCount.txt", path, unlist(counts_colnames$BaseCount))

if(all(temp[1,]==0)) {  # no baseCount data
    dataTable$baseCount <- 0
} else {
    temp <- 
        aggregate(baseCount ~ FASTQ_File_Name + amplconName, data=temp, sum)
    temp$ampNum <- 
        gsub("Amp","", sapply(strsplit(temp$amplconName,"-"),"[",2))
    temp$type <- sapply(strsplit(temp$amplconName,"-"),"[",5)
    temp <- subset(temp, select=-amplconName)
    dataTable <- 
        merge(dataTable, temp,
              by=c("FASTQ_File_Name", "ampNum", "type"), all.x=T)
}
  
# mapqCount
temp <- f_fh("mapqCount.txt", path, unlist(counts_colnames$mapqCount))

if(all(temp[1,]==0)) {  # no mapqCount data
    dataTable$mapqCount <- 0
} else {
    temp <- 
        aggregate(mapqCount ~ FASTQ_File_Name + amplconName, data=temp, sum)
    temp$ampNum <- 
        gsub("Amp","", sapply(strsplit(temp$amplconName,"-"),"[",2))
    temp$type <- sapply(strsplit(temp$amplconName,"-"),"[",5)
    temp <- subset(temp, select=-amplconName)
    dataTable <- 
        merge(dataTable, temp,
              by=c("FASTQ_File_Name", "ampNum", "type"), all.x=T)
}

# NMCount
temp <- f_fh("NMCount.txt", path, unlist(counts_colnames$NMCount))
if(all(temp[1,]==0)) {  # no NMCount data
    dataTable$NMCount <- 0
} else {
    temp <- 
        aggregate(NMCount ~ FASTQ_File_Name + amplconName, data=temp, sum)
    temp$ampNum <- 
        gsub("Amp","", sapply(strsplit(temp$amplconName,"-"),"[",2))
    temp$type <- sapply(strsplit(temp$amplconName,"-"),"[",5)
    temp <- subset(temp, select=-amplconName)
    dataTable <- 
        merge(dataTable, temp,
              by=c("FASTQ_File_Name", "ampNum", "type"), all.x=T)
}


## collect single calculation fields
# offTargetCount
if (file.exists(paste0(path, "/", "offTargetCount.txt")) &&
        file.size(file.path(path, "offTargetCount.txt"))==0) {
    temp <- as.data.frame(matrix(0, ncol=2, nrow=1))
} else if (file.exists(paste0(path, "/", "offTargetCount.txt"))) {
    temp <- read.table(file=file.path(path, "offTargetCount.txt"), 
        header=F, sep="\t", stringsAsFactors=F, as.is=T, comment.char="", 
        quote="")
} else {
    temp <- as.data.frame(matrix(0, ncol=2, nrow=1))
}  
names(temp) <- unlist(counts_colnames$offTargetCount)

singleTable <-
    merge(singleTable, 
        aggregate(offTargetCount ~ FASTQ_File_Name, data=temp, sum),
        by="FASTQ_File_Name", all=T)

# commandLine (table must exist)
temp <- read.table(file=file.path(path,"commandLine.txt"), header = F, sep="\t",
                   stringsAsFactors = F)
colnames(temp) <- c("FASTQ_File_Name","commandLine")
singleTable <- merge(singleTable, temp, by="FASTQ_File_Name", all=T)

# unmappedCount
if (file.exists(paste0(path, "/", "unmappedCount.txt")) &&
        file.size(file.path(path, "unmappedCount.txt"))==0) {
    temp <- as.data.frame(matrix(0, ncol=2, nrow=1))
} else if (file.exists(paste0(path, "/", "unmappedCount.txt"))) {
    temp <- read.table(file=file.path(path, "unmappedCount.txt"), 
        header=F, sep="\t", stringsAsFactors=F, as.is=T, comment.char="", 
        quote="")
} else {
    temp <- as.data.frame(matrix(0, ncol=2, nrow=1))
}  
names(temp) <- unlist(counts_colnames$unmappedCount)

singleTable <-
    merge(singleTable, 
        aggregate(unmappedCount ~ FASTQ_File_Name, data=temp, sum),
        by="FASTQ_File_Name", all=T)

# ComplexityCount
# file with 0 lines
if (file.exists(paste0(path, "/", "ComplexityCount.txt")) &&
        file.size(file.path(path, "ComplexityCount.txt"))==0) {
    temp <- as.data.frame(matrix(0, ncol=4, nrow=1))
# normal file
} else if (file.exists(paste0(path, "/", "ComplexityCount.txt"))) {
    temp <- read.table(file=file.path(path, "ComplexityCount.txt"), 
        header=F, sep="\t", stringsAsFactors=F, as.is=T, comment.char="", 
        quote="")
# file does not exist
} else {
    temp <- as.data.frame(matrix(0, ncol=4, nrow=1))
}
names(temp) <- unlist(counts_colnames$ComplexityCount)

# ComplexityCount if any nonzero counts
if (!(all (temp$CCcount==0))) {
    temp1 <- aggregate(CCcount~FASTQ_File_Name+amplconName+seq, data=temp, sum)
    temp2 <- aggregate(CCcount~FASTQ_File_Name+amplconName, data=temp1, max)
    temp1 <- merge(temp1,temp2,by=c("FASTQ_File_Name","amplconName"))
    temp1 <- temp1[temp1$CCcount.x>offSpringFraction*temp1$CCcount.y,]
    
    uniqueCC <- aggregate(CCcount.x~FASTQ_File_Name+amplconName,
        data=temp1[!grepl(".+[0-9]{3}b$", temp1$amplconName),], length)
    medianCC <- setNames(aggregate(CCcount.x~FASTQ_File_Name+amplconName,
        data=temp1[!grepl(".+[0-9]{3}b$", temp1$amplconName),], median),
        c("FASTQ_File_Name","amplconName","medianCC"))
    totalCC <- 
      setNames(aggregate(CCcount.x~FASTQ_File_Name+gsub("b","", 
        temp1$amplconName), data=temp1, length), 
        c("FASTQ_File_Name", "amplconName", "CCTotalcount"))

    singleTable <- merge(singleTable, uniqueCC, by="FASTQ_File_Name", 
                         all.x=T)
    singleTable <- merge(singleTable, totalCC, 
                         by=c("FASTQ_File_Name","amplconName"), all.x=T)
    singleTable <- merge(singleTable, medianCC, 
                         by=c("FASTQ_File_Name","amplconName"), all.x=T)
    singleTable[is.na(singleTable)] <- 0
    
} else {
    singleTable$CCcount.x <- 0
    singleTable$medianCC <- 0
    singleTable$CCTotalcount <- 0
}


##clean up dataTable headers
dataTable <- dataTable[!is.na(dataTable$type),]
dataTable[is.na(dataTable)] <- 0

#amplicon Abundance with normalization adjustment
singleTable$IS <- 
    as.integer(sub("^.+\\sIS=([0-9]+).*$", "\\1", singleTable$commandLine))  #collect IS input
abundanceTable <- merge(dataTable[dataTable$type=="NT",
    c("FASTQ_File_Name","ampNum","passCount")],
           dataTable[dataTable$type =="IS",c("FASTQ_File_Name","ampNum","passCount")],
           by=c("FASTQ_File_Name","ampNum"))
abundanceTable <- 
    merge(abundanceTable,unique(singleTable[,c("FASTQ_File_Name","IS")]),
    by="FASTQ_File_Name",all.x=T)
abundanceTable$abundance <- 
    abundanceTable$passCount.x/abundanceTable$passCount.y*abundanceTable$IS
norm_a <- norm
norm_a$CHROM <- gsub("Amp","", sapply(strsplit(norm_a$CHROM,"-"),"[",2))

abundanceTable$abundance <-
    abundanceTable$abundance*norm_a$NORMALIZER[match(abundanceTable$ampNum, 
                                                     norm_a$CHROM)]
abundanceTable[is.na(abundanceTable)] <- 0

# calculate VL
viralLoad <- setNames(aggregate(abundance~FASTQ_File_Name, 
    data=abundanceTable,median), c("FASTQ_File_Name","viralLoad"))
singleTable <- merge(singleTable,viralLoad,by="FASTQ_File_Name",all.x = T)
temp <- setNames(aggregate(passCount.x~FASTQ_File_Name, 
    data=abundanceTable,median), c("FASTQ_File_Name","medNTCount"))

singleTable <- merge(singleTable,temp,by="FASTQ_File_Name",all.x = T)
temp <- setNames(aggregate(passCount.y~FASTQ_File_Name, 
    data=abundanceTable,median), c("FASTQ_File_Name","medISCount"))
singleTable <- merge(singleTable,temp,by="FASTQ_File_Name",all.x = T)

#median MN (base changes detected)
temp <- setNames(aggregate(NMCount~FASTQ_File_Name,
    data=dataTable[dataTable$type=="NT",], median), c("FASTQ_File_Name","NTNMCount"))
singleTable <- merge(singleTable, temp, by="FASTQ_File_Name",all.x = T)
temp <- setNames(aggregate(NMCount~FASTQ_File_Name,
    data=dataTable[dataTable$type=="IS",], median), c("FASTQ_File_Name","ISNMCount"))
singleTable <- merge(singleTable, temp, by="FASTQ_File_Name",all.x = T)

#median base count
temp <- setNames(aggregate(baseCount~FASTQ_File_Name,
    data=dataTable[dataTable$type=="NT",], median), c("FASTQ_File_Name","NTBaseCount"))
singleTable <- merge(singleTable, temp, by="FASTQ_File_Name", all.x = T)
temp <- setNames(aggregate(baseCount~FASTQ_File_Name,
    data=dataTable[dataTable$type=="IS",], median), c("FASTQ_File_Name","ISBaseCount"))
singleTable <- merge(singleTable, temp, by="FASTQ_File_Name", all.x = T)

#bad Read Rate per amplicon
dataTable$nmRate <- 
    ifelse(dataTable$NMCount==0, 0, dataTable$NMCount/dataTable$baseCount)
temp <- setNames(aggregate(nmRate~FASTQ_File_Name,
    data=dataTable[dataTable$type=="IS",], median), c("FASTQ_File_Name","ISNMRate"))
singleTable <- merge(singleTable,temp,by="FASTQ_File_Name", all.x = T)
temp <- setNames(aggregate(nmRate~FASTQ_File_Name,
    data=dataTable[dataTable$type=="NT",], median), c("FASTQ_File_Name","NTNMRate"))
singleTable <- merge(singleTable, temp, by="FASTQ_File_Name", all.x = T)

#CC input
singleTable$CCinput <- 
    as.integer(sub("^.+\\sCC=([0-9]+).*$","\\1",singleTable$commandLine))  

# CC yield
singleTable$ccYield <- singleTable$CCcount.x/singleTable$CCinput

#make sure all fields are filled out
ampliconOutput <- data.frame(ampNum=sort(unique(dataTable$ampNum)))
ampliconOutput <- setNames(merge(ampliconOutput,
    unique(dataTable$FASTQ_File_Name), all=T), c("ampNum","FASTQ_File_Name"))
ampliconOutput <- merge(ampliconOutput,
    dataTable[dataTable$type=="NT", 
        c("ampNum", "FASTQ_File_Name", "passCount", "badCount", "NMCount",
          "baseCount", "mapqCount")], by=c("ampNum","FASTQ_File_Name"), all.x = T)
ampliconOutput <- merge(ampliconOutput,
    dataTable[dataTable$type=="IS", c("ampNum", "FASTQ_File_Name", "passCount",
        "badCount", "NMCount", "baseCount", "mapqCount")],
        by=c("ampNum", "FASTQ_File_Name"), all.x = T)
ampliconOutput <- merge(ampliconOutput,
    abundanceTable[ , c("ampNum", "FASTQ_File_Name", "abundance")],
    by=c("ampNum","FASTQ_File_Name"), all.x = T)
ampliconOutput <- merge(ampliconOutput, singleTable[, c("FASTQ_File_Name","ccYield")],
                        all.x=T)
ampliconOutput$ampliconCoverage <- ampliconOutput$abundance * ampliconOutput$ccYield

#median recombination rate
dataTable$medRecRate <- 
    ifelse(dataTable$badCount+dataTable$passCount+dataTable$mapqCount==0,
        0,
        dataTable$badCount/(dataTable$badCount+dataTable$passCount+dataTable$mapqCount))
temp <- setNames(aggregate(medRecRate~FASTQ_File_Name,data=dataTable[dataTable$type=="NT",],median),
                 c("FASTQ_File_Name","NTrecombinantRate"))
singleTable <- merge(singleTable,temp,by="FASTQ_File_Name",all.x = T)
temp <- setNames(aggregate(medRecRate~FASTQ_File_Name,data=dataTable[dataTable$type=="IS",],median),
                 c("FASTQ_File_Name","ISrecombinantRate"))
singleTable <- merge(singleTable,temp,by="FASTQ_File_Name",all.x = T)

# ensure no samples == 0s due to missing file imputation
ampliconOutput <- ampliconOutput[ampliconOutput$FASTQ_File_Name != "0",]
singleTable <- singleTable[singleTable$FASTQ_File_Name != "0",]

# impute missing values introduced through merges with 0
ampliconOutput[is.na(ampliconOutput)] <- 0

#sort amplicon output for output
ampliconOutput <- ampliconOutput[order(ampliconOutput$ampNum),]

#create output table, create by appending
singleTable$output <-
    paste(singleTable$path,# FASTQ_File_Name
    format(singleTable$creationDate,format="%m/%d/%Y %H:%M:%S"),# FASTQ_File_Date
    format(Sys.time(),format="%m/%d/%Y %H:%M:%S"),# SNAQ-SEQ_Analysis_Date
    singleTable$commandLine,# SNAQ-SEQ_Command_Line
    singleTable$viralLoad,# Viral_Load
    singleTable$CCcount.x,# Unique_CC_Count
    singleTable$CCcount.x/singleTable$CCTotalcount,# Fraction_CC_PASS
    singleTable$ccYield,# %CC
    singleTable$medianCC,# Median_CC_Duplication_Rate
    singleTable$ISrecombinantRate,# Median_Recombination_Rate_IS
    singleTable$NTrecombinantRate,# Median_Recombination_Rate_NT
    singleTable$medNTCount,# Median_NT_Reads_Per_Amplicon
    singleTable$medISCount,# Median_IS_Reads_Per_Amplicon
    singleTable$viralLoad * singleTable$CCcount.x/singleTable$CCinput, # Median_NT_Coverage
    singleTable$NTNMCount, # Median_NT_NM
    singleTable$ISNMCount ,# Median_IS_NM
    singleTable$NTBaseCount,# Median_NT_Base_Count
    singleTable$ISBaseCount,# Median_IS_Base_Count
    singleTable$NTNMRate,# Median_NT_Bad_Reads
    singleTable$ISNMRate,# Median_IS_Bad_Reads
    singleTable$unmappedCount,# Unmapped_Read_Count
    singleTable$offTargetCount,# Off-Target_Read_Count
    sapply(singleTable$FASTQ_File_Name,
        function(x) paste(ampliconOutput$passCount.x[ampliconOutput$FASTQ_File_Name==x],collapse = ",")), # NR001 PaSS NT Reads
    sapply(singleTable$FASTQ_File_Name,
        function(x) paste(ampliconOutput$passCount.y[ampliconOutput$FASTQ_File_Name==x],collapse = ",")), # IR001 PASS IS Reads
    sapply(singleTable$FASTQ_File_Name,
        function(x) paste(ampliconOutput$abundance[ampliconOutput$FASTQ_File_Name==x],collapse = ",")), # AA029 NT Amplicon Abundance
    sapply(singleTable$FASTQ_File_Name,
        function(x) paste(ampliconOutput$ampliconCoverage[ampliconOutput$FASTQ_File_Name==x],collapse = ",")), # CV001 NT Genomic Coverage
    sapply(singleTable$FASTQ_File_Name,
        function(x) paste(ampliconOutput$badCount.x[ampliconOutput$FASTQ_File_Name==x],collapse = ",")), # NX001 NT Recombinant Read Count
    sapply(singleTable$FASTQ_File_Name,
        function(x) paste(ampliconOutput$badCount.y[ampliconOutput$FASTQ_File_Name==x],collapse = ",")), # IX001 IS Recombinant Read count
    sapply(singleTable$FASTQ_File_Name,
        function(x) paste(ampliconOutput$NMCount.x[ampliconOutput$FASTQ_File_Name==x],collapse = ",")), # NN001 NT NM count by amplicon
    sapply(singleTable$FASTQ_File_Name,
        function(x) paste(ampliconOutput$NMCount.y[ampliconOutput$FASTQ_File_Name==x],collapse = ",")), # IN001 IS NM Count by amplicon
    sapply(singleTable$FASTQ_File_Name,
        function(x) paste(ampliconOutput$baseCount.x[ampliconOutput$FASTQ_File_Name==x],collapse = ",")), # NB001 NT Base Count by amplicon
    sapply(singleTable$FASTQ_File_Name,
        function(x) paste(ampliconOutput$baseCount.y[ampliconOutput$FASTQ_File_Name==x],collapse = ",")), # IB001 IS Base Count by amplicon
    sapply(singleTable$FASTQ_File_Name,
        function(x) paste(ampliconOutput$mapqCount.x[ampliconOutput$FASTQ_File_Name==x],collapse = ",")), # NBA001 NT mapq counts by amplicon
    sapply(singleTable$FASTQ_File_Name,
        function(x) paste(ampliconOutput$mapqCount.y[ampliconOutput$FASTQ_File_Name==x],collapse = ",")), # IBA001 IS mapq counts by amplicon
        sep=separator)

headerFields <- c("FASTQ_File_Name", "FASTQ_File_Date", "SNAQ-SEQ_Analysis_Date", 
    "SNAQ-SEQ_Command_Line", "Viral_Load", "Unique_CC_Count", "Fraction_CC_PASS", "%CC",
    "Median_CC_Duplication_Rate", "Median_Recombination_Rate_IS", "Median_Recombination_Rate_NT", 
    "Median_NT_Reads_Per_Amplicon", "Median_IS_Reads_Per_Amplicon", "Median_NT_Coverage", 
    "Median_NT_NM", "Median_IS_NM", "Median_NT_Base_Count", "Median_IS_Base_Count",
    "Median_NT_Bad_Reads", "Median_IS_Bad_Reads", "Unmapped_Read_Count",
    "Off-Target_Read_Count",
    paste0("NR", norm_a$CHROM), paste0("IR", norm_a$CHROM), paste0("AA", norm_a$CHROM),
    paste0("CV", norm_a$CHROM), paste0("NX", norm_a$CHROM), paste0("IX", norm_a$CHROM), 
    paste0("NN", norm_a$CHROM), paste0("IN", norm_a$CHROM), paste0("NB", norm_a$CHROM), 
    paste0("IB", norm_a$CHROM), paste0("NBA", norm_a$CHROM), paste0("IBA", norm_a$CHROM))

headerString <- paste(headerFields, collapse=",")
#headerString <- paste(headerFields, collapse=", ")

# for single reads: append to most recent previous SNAQ-SEQ analysis file if present
if (nrow(singleTable) == 1 & (any(grepl("SNAQ-SEQ-Analysis", dir(path2))))) {
    outfile_name <- 
        paste0(path2, "/",
            rev(sort(grep("SNAQ-SEQ-Analysis-[0-9]+_[0-9]+.csv", dir(path2), 
                          value=T)))[1])
    write.table(singleTable$output, 
        file=outfile_name, quote = F, col.names = F, row.names = F, append = T)
} else {
    outfile_name <- 
        paste0(path2, "/", "SNAQ-SEQ-Analysis", "-", format(Sys.time(), 
            "%Y%m%d_%H%M%S"),".csv")
    write.table(c(headerString,singleTable$output), 
        file=outfile_name, quote = F, col.names = F, row.names = F)
}
