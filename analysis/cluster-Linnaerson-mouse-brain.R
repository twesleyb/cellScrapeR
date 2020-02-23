#!/usr/bin/env Rscript

## Perform Kmeans clustering of the mouse brain cell cluster dataset.
## Expression values are the log mean of a genes expression in that cell cluster.
## Duplicate rowws (genes) are summed.
## Genes that are expressed in <50% of samples are removed.
## Missing values are imputed with the KNN algorithm.
## Kmeans clustering is performed with k=N cell clusters (265).

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
n_clusters <- ncol(adjm)

# Handle duplicate rows (genes), by summing the duplicates.
adjm <- adjm %>% group_by(X) %>% summarize_all(sum)
adjm <- as.data.table(adjm)
genes <- adjm$X
adjm$X <- NULL
adjm <- as.matrix(adjm)
rownames(adjm) <- genes

# Load Ensembl-Gene Symbol map.
myfile <- file.path(downdir,'Gene_Ensembl_Map.csv')
gene_map <- fread(myfile,drop=1,header=TRUE)

# Load cell cluster markers.
myfile <- file.path(downdir,'Cell_Cluster_Markers.csv')
markers <- fread(myfile,drop=1,header=TRUE)

# Collect cell markers as a named list.
markers <- markers  %>% group_by(Cluster) %>% group_split() 
cell_markers <- lapply(markers,function(x) unlist(strsplit(x$Genes," ")))
names(cell_markers) <- sapply(markers,function(x) x$Cluster)

# Map genes to Ensembl Ids.
cell_markers <- lapply(cell_markers,function(x) {
			       idx <- match(x,gene_map$Symbol)
			       names(x) <- gene_map$Ensembl[idx]
			       return(x)
})

# Coerce cell markers list to a named vector.
cell_markers <- unlist(cell_markers)
cell <- sapply(strsplit(names(cell_markers),"\\."),"[",1)
gene <- sapply(strsplit(names(cell_markers),"\\."),"[",2)
names(cell) <- gene
cell_markers <- cell

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
message(paste("... Number of remaining genes:",nkeep))

# Impute the remaining missing values as MNAR with KNN.
message("Imputing missing values with KNN algorithm...")
adjm <- quiet({impute.knn(adjm)$data})

# Perform bicor.
message("Analyzing correlations between genes with midweight bicorrelation...")
cormat <- quiet({WGCNA::bicor(t(adjm))})

# Save to file.
myfile <- file.path(downdir,"Expression_Bicor_Matrix.csv")
fwrite(as.data.table(cormat),myfile)

# Perform KNN mean clustering.
n <- 1000
n_rand <- sample(ncol(cormat),n)
k <- n_clusters
nstart <- 1
iter.max <- 10
alg <- c("Hartigan-Wong", "Lloyd", "Forgy","MacQueen")[1]
message(paste0("Performing kmeans clustering (k=",n_clusters,
	      ") using the ",alg," algorithm..."))
clusters <- kmeans(cormat[n_rand,n_rand], centers=k, iter.max, nstart, algorithm=alg)

# Extract clusters.
partition <- clusters$cluster
names(partition) <- colnames(cormat)

# Split into list of cell clusters.
cell_clusters <- split(partition,partition)
names(cell_clusters) <- paste0("C",names(cell_clusters))

# Save.
mfyile <- file.path(rdatdir,"Linaerson_Mouse_Brain_Cell_Clusters.RData")
saveRDS(cell_clusters,myfile)
