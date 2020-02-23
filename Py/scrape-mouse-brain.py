#!/usr/bin/env python3

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
genes = ds.ra['Accession']

# List comprehension to get expression data for every gene.
# Not sure why it has to be done like this...
data = [ds[ds.ra.Accession == gene,:][0] for gene in genes]

# Create a df and write to csv.
df = pd.DataFrame(data,index=genes,columns=clusters)
df.to_csv('Expression_Matrix.csv')

# Calculate bicor in R.
from pandas import read_csv
cormat = read_csv('Expression_Bicor_Matrix.csv')






