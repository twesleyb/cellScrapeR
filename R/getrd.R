#' getrd - get root directory
getrd <- function(dpattern=".git",fpattern=NULL,max_trys=5){
	here <- getwd()
	if (!is.null(dpattern) & is.null(fpattern)) {
        # Loop to search for directory pattern.
		root <- FALSE
		i <- 0
		while (!root & i < max_trys) {
			root <- dpattern %in% basename(list.dirs(here,recursive=FALSE))
			if (!root) { here <- dirname(here) ; i = i+1 }
		}
	} else if (!is.null(fpattern) & is.null(dpattern)) {
	# Loop to search for file pattern.
		root <- FALSE
		i <- 0
		while (!root & i < max_trys) {
			root <- fpattern %in% list.files(here)
			if (!root) { here <- dirname(here) ; i = i+1 }
		}
	} else {
		stop("Please provide a file pattern or directory pattern.")
	}
	# Check if root was found.
	if (root) { 
		root_directory <- here 
		return(root_directory)
	} else {
		stop(paste("Unable to find root directory after",max_trys,"."))
	}
}
