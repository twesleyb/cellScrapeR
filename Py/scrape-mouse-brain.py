#!/usr/bin/env python3

import os
from os.path import dirname, join

here = os.getcwd()
root = dirname(here)
downdir = join(root,"downloads")


import loompy

myfile = join(downdir,"l5_all.agg.loom")
ds = loompy.connect(myfile)

ty_list =open('tylers_list.txt','r')
lines = ty_list.read().splitlines()
ty_list.close()

exp_dat = [ds.ca.ClusterName]
errors = []

count=0
accsn = []
for i in lines:
    try:
        exp_dat.append(ds[ds.ra["Accession"] == i,:][0])
        accsn.append(i)
    except:
        errors.append(i)
    count += 1
    print(count)
    
import pandas as pd

df= pd.DataFrame(exp_dat,columns=exp_dat.pop(0))
df['gene'] = accsn

cols = list(df)
cols.insert(0, cols.pop(cols.index('gene')))
df = df.loc[:, cols]

df.to_csv('tyler_wbmatrix.csv', sep=',')
