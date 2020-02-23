#!/usr/bin/env Rscript

# Perform Kmeans clustering of the mouse brain cell cluster dataset.
# Expression values are the log mean of a genes expression in that cell cluster.
# Duplicate rowws (genes) are summed.
# Genes that are expressed in <50% of samples are removed.
# Missing values are imputed with the KNN algorithm.
# Kmeans clustering is performed with k=N cell clusters (265).

## User parameters:
n <- "all" # Which genes to analyze? Or a number of random genes to analyze.
## Other parameters for clustering:
nstart <- 10
iter.max <- 1000
alg <- c("Hartigan-Wong", "Lloyd", "Forgy","MacQueen")[1]

# Imports.
suppressPackageStartupMessages({
	library(impute)
	library(data.table)
	library(dplyr)
})


# Directories.
here <- getwd()
root <- dirname(here)
downdir <- file.path(root,"downloads")
rdatdir <- file.path(root,"rdata")

# Functions.
# Use quiet to suppress unwanted messages from bicor() and impute.knn().
source(file.path(root,"R","quiet.R"))

# Load the data.
myfile <- file.path(downdir,'Expression_Matrix.csv')
adjm <- read.csv(myfile)

# Handle duplicate rows (genes), by summing the duplicates.
adjm <- adjm %>% group_by(X) %>% summarize_all(sum)
adjm <- as.data.table(adjm)
genes <- adjm$X
adjm$X <- NULL
adjm <- as.matrix(adjm)
rownames(adjm) <- genes

# Total number of cell type clusters.
n_clusters <- ncol(adjm)

# Remove genes with too many missing values from expression data.
message("Removing genes with too many missing values...")
percent_missing <- apply(adjm,1,function(x) sum(x==0)/length(x))
out <- percent_missing > 0.5
nout <- formatC(sum(out),big.mark=",")
adjm <- adjm[!out,]
nkeep <- formatC(nrow(adjm),big.mark=",")

# Status report.
message(paste("... Number of genes that are expressed in less than 50%",
	      "of cell clusters:",nout))
message(paste("... Number of remaining genes:",nkeep,"\n"))

# Impute the remaining missing values as MNAR with KNN.
message("Imputing missing values with KNN algorithm...\n")
adjm <- quiet({impute.knn(adjm)$data})

# Perform bicor.
message("Analyzing correlations between genes with midweight bicorrelation...")
cormat <- quiet({WGCNA::bicor(t(adjm))})

# Save to file.
myfile <- file.path(downdir,"Expression_Bicor_Matrix.csv")
if (!file.exists(myfile)) { fwrite(as.data.table(cormat),myfile) }

# Which genes to analyze?
if (n != "all") {
	idx <- idy <- sample(ncol(cormat),n) 
} else {
	idx <- idy <- c(1:ncol(cormat))
}

# Perform KNN mean clustering.
k <- n_clusters
message(paste0("Performing kmeans clustering (k=",n_clusters,
	      ") using the ",alg," algorithm...\n"))
clusters <- kmeans(cormat[idx,idy], centers=k, iter.max, nstart, algorithm=alg)

# Extract clusters.
partition <- clusters$cluster
names(partition) <- colnames(cormat)[idx]

# Split into list of cell clusters.
cell_clusters <- split(partition,partition)
names(cell_clusters) <- paste0("C",names(cell_clusters))

# Save.
myfile <- file.path(rdatdir,"Linaerson_Mouse_Brain_Cell_Clusters.RData")
saveRDS(cell_clusters,myfile)

# Status.
message("Done!")
