getJSON <- function(url){
	# Get json data from UCSC cells website.
	library(data.table)
	library(rjson)
	destfile <- basename(url)
	download.file(url,destfile)
	data <- fromJSON(paste(readLines(destfile,warn=FALSE),collapse=""))
	unlink(destfile)
	return(data.table(data))
}
