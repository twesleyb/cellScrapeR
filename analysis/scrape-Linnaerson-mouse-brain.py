#!/usr/bin/env python3

# Imports.
import os
import wget
import loompy
import pandas as pd
from os.path import isfile, dirname, basename, join

# Directories.
here = os.getcwd()
root = dirname(here)
downdir = join(root,"downloads")

# Download the loom object.
url = "https://storage.googleapis.com/linnarsson-lab-loom/l5_all.agg.loom"
loom_file = join(downdir,basename(url))
if not isfile(loom_file): wget.download(url,out=downdir)

# Load the data.
ds = loompy.connect(loom_file,mode='r',validate=False)

# Get clusters, accession ids, gene symbols, and cell marker genes.
clusters = list(ds.ca['ClusterName'])
gene_ids = ds.ra['Accession']
genes = ds.ra['Gene']
cell_markers = ds.ca['MarkerGenes']

# Scrape the expression data.
# Use list comprehension to get expression data for every gene.
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
