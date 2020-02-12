#!/usr/bin/env Rscript

# imports
library(data.table)
library(dplyr)
library(getPPIs)

# load functions
devtools::load_all()

# directories
here <- getwd()
root <- dirname(here)
datadir <- file.path(root,"data")

# urls to data
urls <- list(
	     data = "https://cells.ucsc.edu/autism/exprMatrix.tsv.gz",
	     meta = "https://cells.ucsc.edu/autism/meta.tsv",
	     coords = "https://cells.ucsc.edu/autism/tSNE.coords.tsv.gz",
	     json = "https://cells.ucsc.edu/autism/desc.json")

# download the data
#data <- getData(urls$data) # this is really slow!
meta <- getMeta(urls$meta)
json <- getJSON(urls$json)

# Split data into Control and ASD diagnoses.
submeta <- meta %>% group_by(diagnosis) %>% group_split()
names(submeta) <- unique(meta$diagnosis)

# get control data.
df <- subset(meta,meta$diagnosis == "Control")

# Convert human genes to mouse.
msEntrez <- getHomologs(genes,taxid=10090)
df$msEntrez <- msEntrez 

# Collect cell clusters from control group.
cell_clusters <- split(df$msEntrez,df$cluster)

# Write as gmt.
myfile <- file.path(datadir,"Velmeshev_Cell_Clusters.gmt")
write_gmt(cell_clusters,urls$data,myfile)

# Create anRichment geneSet collection.
createGeneSet <- function(genes) {
       geneSet <- newGeneSet(geneEntrez = genes,
			      geneEvidence = "IEA",
			      geneSource = "Velmeshev et al., 2020",
			      ID = pathway_name, # diseaseId
			      name = pathway_name, # Shortened disease name
			      description = " literature",
			      source = "httpsneLists/data",
			      organism = "mouse",
			      internalClassification = "DBD",
			      groups = "CompiledDBD",
			      lastModified = Sys.Date())
return(geneSet)
}

# Loop to build gene sets.
geneSets <- lapply(seq_along(cell_clusters),function(x) {
			       createGeneSet(disease_groups[[x]],names(disease_groups)[x])
			      })

# Define group.
PLgroup <- newGroup(name = "CompiledDBD", 
		   description = "Compiled DBD genes from several databases and the literature.",
		   source = "https://github.com/twesleyb/geneLists/data")

# Combine go collection.
DBDcollection <- newCollection(dataSets=geneSetList,groups=list(PLgroup))

# Save.
