#' write_gmt
write_gmt <- function(gmt_list,gmt_source,gmt_file) {
	gmt_names <- names(gmt_list)
	gmt_genes <- sapply(gmt_list,function(x) paste(x,collapse="\t"))
	gmt <- paste(gmt_names,gmt_source,gmt_genes,sep="\t")
	myfile <- file(gmt_file)
	writeLines(gmt,myfile)
	close(myfile)
}


