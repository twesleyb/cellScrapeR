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
	datasets <- fromJSON(paste(readLines(json_file,warn=FALSE), collapse=""))
	unlink(json_file)
	 # Un-nest list.
	datasets <- lapply(datasets,function(x) unlist(x,recursive=FALSE))
	# Save to RData.
	myfile <- gsub("json","RData",json_file)
	saveRDS(datasets,myfile)
}
