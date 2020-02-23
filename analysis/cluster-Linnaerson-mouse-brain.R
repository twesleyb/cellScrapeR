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
	library(dplyr)
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

# Load Ensembl-Gene Symbol map.
myfile <- file.path(downdir,'Gene_Ensembl_Map.csv')
gene_map <- fread(myfile,drop=1,header=TRUE)
gene_map

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

cell_markers <- unlist(cell_markers)
cell <- sapply(strsplit(names(cell_markers),"\\."),"[",1)
gene <- sapply(strsplit(names(cell_markers),"\\."),"[",2)
names(cell) <- gene
cell_markers <- cell

# Remove genes with too many missing values from expression data.
percent_missing <- apply(adjm,1,function(x) sum(x==0)/length(x))
out <- percent_missing > 0.5
nout <- formatC(sum(out),big.mark=",")
adjm <- adjm[!out,]

# Status report.
message(paste("Number of genes that are expressed in less than 50%",
	      "of cell clusters:",nout))
message(paste("Number of remaining genes:",nrow(adjm)))

# Impute the remaining missing values as MNAR with KNN.
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
clusters <- kmeans(cormat, centers=k, iter.max, nstart, algorithm=alg)

# Extract clusters.
partition <- clusters$cluster
names(partition) <- colnames(cormat)

# Split into list of cell clusters.
cell_clusters <- split(partition,partition)
names(cell_clusters) <- paste0("C",names(cell_clusters))

# All cell markers.
all_markers <- unlist(lapply(cell_markers,names),use.names=FALSE)

# How many cell markers were clustered?
sum(names(partition) %in% all_markers)

idx <- which(sapply(cell_clusters,function(x) sum(names(x) %in% all_markers))==2)
subclust <- cell_clusters[idx]

