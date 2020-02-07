#!/usr/bin/env Rscript

library(data.table)

urls <- list(
	     data = "https://cells.ucsc.edu/autism/exprMatrix.tsv.gz",
	     meta = "https://cells.ucsc.edu/autism/meta.tsv",
	     coords = "https://cells.ucsc.edu/autism/tSNE.coords.tsv.gz",
	     json = "https://cells.ucsc.edu/autism/desc.json")


getData <- function(url) { 
	# Convienence function to download data from UCSC cells website.
	require(data.table)
	return(fread(cmd=paste("curl",url,"| zcat"))) 
}

getMeta <- function(url) {
	# Convienence function to download data from UCSC cells website.
	require(data.table)
	return(data.table(fread(cmd=paste("curl",url)),row.names=1))
}

getJSON <- function(url){
	library(rjson)
	destfile <- basename(url)
	download.file(url,destfile)
	data <- fromJSON(paste(readLines(destfile,warn=FALSE),collapse=""))
	unlink(destfile)
	return(data)
}

# Download the data.
# This is slow!
data <- getData(urls$data)

meta <- getMeta(urls$meta)
json <- getJSON(urls$json)


library(dplyr)

submeta <- meta %>% group_by(diagnosis) %>% group_split()
names(submeta) <- unique(meta$diagnosis)
gene_clusters <- lapply(submeta,function(x) split(x$genes,x$cluster))

df <- subset(meta,meta$diagnosis == "Control")
cell_clusters <- split(df$genes,df$cluster)






