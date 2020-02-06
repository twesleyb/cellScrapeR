#!/usr/bin/env Rscript

updateDatasets <- function(){
	suppressPackageStartupMessages({
		library(rjson)
	})
	# Get all links to SCell datasets.
	here <- getwd()
	root <- dirname(here)
	funcdir <- file.path(root,"Py")
	rdatdir <- file.path(root,"rdata")
	# Call getSCellDatasets() to collect all available datasets.
	cmd <- file.path(funcdir,"getDatasets.py")
	json_file <- system(cmd,intern=TRUE,
			    ignore.stdout=FALSE,ignore.stderr=FALSE)
	datasets <- fromJSON(paste(readLines(json_file), collapse=""))
	unlink(json_file)
	# Save to RData.
	myfile <- gsub("json","RData",json_file)
	saveRData(datasets,myfile)
}

updateDatasets()
