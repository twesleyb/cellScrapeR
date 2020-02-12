getData <- function(url) { 
	# Download data from UCSC cells website.
	library(data.table)
	return(fread(cmd=paste("curl",url,"| zcat"))) 
}
