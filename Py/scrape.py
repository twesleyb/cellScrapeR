#!/usr/bin/env python3

# Parameters.
BASEURL = "https://cells.ucsc.edu/"
EXTENSION = ".tsv.gz"

import os
import re
from datetime import date
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.chrome.options import Options

# Chrome options and path to chromedriver.
chrome_options = Options()
chrome_options.add_argument("--headless")
chrome = "/home/twesleyb/src/chromedriver.exe"

# Start headless chromedriver session.
driver = webdriver.Chrome(chrome,options=chrome_options)
driver.get(BASEURL)

# All dataset buttons.
buttons = driver.find_elements_by_class_name('list-group-item')

# Iterate through buttons, get page source data.
soup = list()
for button in buttons:
    button.click()
    soup.append(BeautifulSoup(driver.page_source,"xml"))

# Get links to raw data.
regex = re.compile("['a-z']*" + EXTENSION)
hrefs = [page.find_all('a', href = regex) for page in soup]

# Remove empty elements.
empty = [len(href)==0 for href in hrefs]
buttons = [button for (button,empty) in zip(buttons,empty) if not empty]
soup = [page for (page, empty) in zip(soup, empty) if not empty]
hrefs = [href for (href, empty) in zip(hrefs,empty) if not empty]

# Get dataset names.
data_names = [button.text.split("\n")[-1] for button in buttons]

# Convert hrefs to filenames--nested list comphrension.
data_urls = [[BASEURL + link.text for link in links] for links in hrefs]

# Bind as a dict. 
datasets = dict(zip(data_names,data_urls))

# Write to file.
here = os.getcwd()
now = str(date.today())
myfile = os.path.join(here,"data",now + "_cell-datasets.txt")
f = open(myfile,"w")
f.write(str(datasets))
f.close()
