#!/usr/bin/env python3

import os
import re
from datetime import date
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.chrome.options import Options

def getCellDatasets():
    ''' Collect all available datasets from cells.ucsc.edu. '''
    ## Default parameters.
    LOG_LEVEL = 3
    META_EXTENSION = ".json"
    DATA_EXTENSION = ".tsv.gz"
    BASEURL = "https://cells.ucsc.edu/"
    CHROME_DRIVER = "/home/twesleyb/src/chromedriver.exe"
    # Chrome options and path to chromedriver.
    chrome = CHROME_DRIVER 
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    chrome_options.add_argument('log-level=' + str(LOG_LEVEL))
    # Start headless chromedriver session.
    driver = webdriver.Chrome(chrome,options=chrome_options)
    driver.get(BASEURL)
    # All dataset buttons.
    # While loop to insure that we successfully collect buttons.
    buttons = []
    while len(buttons) <= 0:
        buttons = driver.find_elements_by_class_name('list-group-item')
    # Iterate through buttons, get page source data.
    soup = list()
    for button in buttons:
        button.click()
        soup.append(BeautifulSoup(driver.page_source,"xml"))
    # Get links to raw data.
    regex = re.compile("['a-z']*" + DATA_EXTENSION)
    hrefs = [page.find_all('a', href = regex) for page in soup]
    # Get links to meta data.
    regex = re.compile("['a-z']*" + META_EXTENSION)
    json = [page.find_all('a', href = regex) for page in soup]
    # Remove empty elements.
    empty = [len(href)==0 for href in hrefs]
    buttons = [button for (button,empty) in zip(buttons,empty) if not empty]
    soup = [page for (page, empty) in zip(soup, empty) if not empty]
    hrefs = [href for (href, empty) in zip(hrefs,empty) if not empty]
    json = [json for (json, empty) in zip(json,empty) if not empty]
    # Get dataset names.
    data_names = [button.text.split("\n")[-1] for button in buttons]
    # Convert hrefs to filenames urls--nested list comprehension.
    data_urls = [[BASEURL + link.text for link in links] for links in hrefs]
    data_urls = [dict(zip(["Datasets"], [urls] )) for urls in data_urls]
    # Convert json to urls using nested list comprehension.
    json_urls = [[BASEURL + link.get('href') for link in links] for links in json]
    json_urls = [dict(zip(["Metadata"], [urls] )) for urls in json_urls]
    # Bind names, dataset urls, and json metadata urls as dict.
    datasets = dict(zip(data_names,list(zip(data_urls,json_urls))))
    # Write to file.
    here = os.getcwd()
    root = os.path.dirname(here)
    now = str(date.today())
    myfile = os.path.join(root,"data",now + "_cell-datasets.txt")
    f = open(myfile,"w")
    f.write(str(datasets))
    f.close()
# EOF
    
if __name__ == '__main__':
    getCellDatasets()
