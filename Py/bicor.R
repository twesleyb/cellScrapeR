#!/usr/bin/env Rscript
# Perform bicor.
bicor <- function(path2adjm){
	adjm <- read.csv(path2adjm)
	cormat <- WGCNA::bicor(adjm)
	return(dm)
}

# Load the data.
adjm <- read.csv('Expression_Matrix.csv')
rownames(adjm) <- adjm$X
adjm$X <- NULL
adjm <- as.matrix(adjm)

# Perform bicor.
cormat <- WGCNA::bicor(t(adjm))

# Save to file.
message("Saving data!")
data.table::fwrite(cormat,"Expression_Bicor_Matrix.csv")
