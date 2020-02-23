#!usr/bin/env Rscript

# Evaluate accuracy of clustering.

# Directories.
here <- getwd()
root <- dirname(here)
rdatdir <- file.path(root,"rdata")
downdir <- file.path(root,"downloads")

# Load clustering result.
myfile <- file.path(rdatdir,"")
partition <- readRDS(myfile)

# Load cell type markers.
myfile <- file.path(downdir,"Cell_Cluster_Markers.csv")

# How many cell markers are grouped together?
