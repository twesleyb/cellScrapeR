# Get SCdata from UCSC database.

# Function to download data with fread.
getData <- function(url){ 
	# Convienence function to download data from UCSC cells website.
	return(fread(cmd=paste("curl",url,"| zcat"))) 
}

scrapeCells <- function(dataset){

	# FIXME: datasets has wrong urls!!

	suppressPackageStartupMessages({
	library(data.table)
	})
	# Directories.
	here <- getwd()
	root <- dirname(here)
	rdatdir <- file.path(root,"rdata")
	# Load SC datasets.
	myfiles <- list.files(rdatdir,pattern="*cell-datasets.RData",
			      full.names=TRUE)
	datasets <- readRDS(myfiles[1])
	# Get urls to dataset of interest.
	data_urls <- datasets[[dataset]]
	filenames <- basename(data_urls$ExprData)

	message(paste("Downloading",length(filenames)),"files!")
	# Download the expresion data.
	data <- lapply(data_urls$ExprData,getData)
	names(data) <- sapply(strsplit(filenames,"\\.tsv"),"[",1)
	# Download the meta data.
	meta <- data.table(fread(cmd=paste("curl",data_urls$MetaData)),
			   row.names=1)
	# Return list of data.
	return(list("ExprData"=data,"MetaData"=meta))
}

data <- scrapeCells(dataset="Autism")
