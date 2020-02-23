#!/usr/bin/env python3

# Imports.
import os
import loompy
import pandas as pd
from os.path import dirname, join

# Directories.
here = os.getcwd()
root = dirname(here)
downdir = join(root,"downloads")

# Load the data.
myfile = join(downdir,"l5_all.agg.loom")
ds = loompy.connect(myfile,mode='r',validate=False)

# Scrape all of the data.
clusters = list(ds.ca['ClusterName'])
gene_ids = ds.ra['Accession']
genes = ds.ra['Gene']

# Scrape cell markers.
cell_markers = ds.ca['MarkerGenes']

# List comprehension to get expression data for every gene.
# Not sure why it has to be done like this...
data = [ds[ds.ra.Accession == gene_id,:][0] for gene_id in gene_ids]

# Create a df and write to csv.
df = pd.DataFrame(data,index=genes,columns=clusters)
myfile = join(downdir,'Expression_Matrix.csv')
df.to_csv(myfile)

# Create df of cell markers and write to csv.
markers = pd.DataFrame({'Cluster':clusters,'Genes':cell_markers})
myfile = join(downdir,'Cell_Cluster_Markers.csv')
markers.to_csv(myfile)

# Create a df of ensembl-gene name annotations.
gene_map = pd.DataFrame({'Symbol':genes,'Ensembl':gene_ids})
myfile = join(downdir,'Gene_Ensembl_Map.csv')
gene_map.to_csv(myfile)
