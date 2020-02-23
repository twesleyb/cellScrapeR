#!/usr/bin/env Rscript
# Perform bicor of Mouse brain cell cluster matrix.

# Load the data.
adjm <- read.csv('Expression_Matrix.csv')
rownames(adjm) <- adjm$X
adjm$X <- NULL
adjm <- as.matrix(adjm)

# Perform bicor.
message("Performing bicor!")
cormat <- WGCNA::bicor(t(adjm))

# Save to file.
message("Saving data!")
data.table::fwrite(cormat,"Expression_Bicor_Matrix.csv")
