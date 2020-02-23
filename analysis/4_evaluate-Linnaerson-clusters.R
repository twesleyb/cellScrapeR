#!usr/bin/env Rscript

# Evaluate accuracy of clustering.

# Directories.
here <- getwd()
root <- dirname(here)
rdatdir <- file.path(root,"rdata")
downdir <- file.path(root,"downloads")

# Load clustering result.
myfile <- file.path(rdatdir,"Linaerson_Mouse_Brain_Cell_Clusters.RData")
partition <- readRDS(myfile)

# Load cell type markers.
myfile <- file.path(downdir,"Cell_Cluster_Markers.csv")
cell_markers <- data.table::fread(myfile,drop=1,header=TRUE)

# How many cell markers are grouped together?
marker_list <- lapply(cell_markers$Genes,function(x) strsplit(x,"\\ ")[[1]])
names(marker_list) <- cell_markers$Cluster

# There are 6 cell marker genes for every cell type.
marker_partition <- unlist(marker_list,use.names=FALSE)
names(marker_partition) <- rep(names(marker_list),each=6)

# Accuracy?
n_together <- sapply(marker_list,function(x) {
			     max(sapply(partition,function(y) sum(x %in% names(y))))
})
accuracy <- sum(n_together)/(length(n_together)*6)
message(paste("Percent accuracy:",round(100*accuracy,3)))
