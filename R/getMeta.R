getMeta <- function(url) {
	# Download metadata from UCSC cells website.
	library(data.table)
	return(data.table(fread(cmd=paste("curl",url)),row.names=1))
}
