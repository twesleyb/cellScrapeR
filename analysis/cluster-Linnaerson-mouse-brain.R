#!/usr/bin/env Rscript

## Perform Kmeans clustering of mouse brain cells.
## Expression values are the log mean of a genes expression in that cell cluster.
## Remove genes that are expressed in <50% of samples.
## Impute missing values.
## Additional normalization???

# Imports.
suppressPackageStartupMessages({
	library(impute)
	library(data.table)
})

# Functions.
suppressWarnings({ devtools::load_all() })

# Directories.
here <- getwd()
root <- getrd()
downdir <- file.path(root,"downloads")

# Load the data.
myfile <- file.path(downdir,'Expression_Matrix.csv')
adjm <- read.csv(myfile)
rownames(adjm) <- adjm$X
adjm$X <- NULL
adjm <- as.matrix(adjm)

# Remove genes with too many missing values.
percent_missing <- apply(adjm,1,function(x) sum(x==0)/length(x))
out <- percent_missing > 0.5
nout <- formatC(sum(out),big.mark=",")
message(paste("Number of genes that are expressed in less than 50%",
	      "of cell clusters:",nout))
adjm <- adjm[!out,]

# Impute the remaining missing values as MNAR.
adjm <- impute.knn(adjm)$data

# Perform bicor for a subset of genes.
n <- 1000
rand_genes <- sample(nrow(adjm),n)
cormat <- WGCNA::bicor(t(adjm[rand_genes,]))

# Save to file.
myfile <- file.path(downdir,"Expression_Bicor_Matrix.csv")
fwrite(cormat,myfile)

# Load bicor expression matrix.
myfile <- file.path(downdir,'Expression_Bicor_Matrix.csv')
cormat <- fread(myfile)
rownames(cormat) <- colnames(cormat)

# Perform KNN mean clustering.
k <- ncol(adjm)
nstart <- 1
iter.max <- 10
alg <- c("Hartigan-Wong", "Lloyd", "Forgy","MacQueen")[1]
partition <- kmeans(cormat, centers=k, iter.max, nstart, algorithm=alg)

sum(table(partition$cluster))


