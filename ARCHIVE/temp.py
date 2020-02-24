#!/usr/bin/env python3

import os
import re
import sys
import json
from time import sleep
from datetime import date
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.chrome.options import Options

def getDatasets(chrome_driver ="/home/twesleyb/src/chromedriver.exe",
    ''' Collect all available datasets from cells.ucsc.edu. '''

    ## Default parameters.
    LOG_LEVEL = 3
    META_EXTENSION = ".tsv"
    DATA_EXTENSION = ".tsv.gz"
    BASEURL = "https://cells.ucsc.edu/"
    CHROME_DRIVER = "/home/twesleyb/src/chromedriver.exe"
    chrome_driver = CHROME_DRIVER
    
    # Chrome options and path to chromedriver.
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    chrome_options.add_argument('log-level=' + str(LOG_LEVEL))
    chrome_options.add_experimental_option('excludeSwitches',['enable-logging'])
    # Start headless chromedriver session.
    driver = webdriver.Chrome(chrome_driver,options=chrome_options)
    driver.get(BASEURL)


xpath = "//a[@role='button'][@class='list-group-item tpDatasetButton']"
buttons = driver.find_elements_by_xpath(xpath)

data = list()

for button in buttons:

    button.click()
    sleep(1)
    tabs = driver.find_elements_by_class_name('tpDatasetTab')

    tabs[2].click()
    sleep(1)
    hrefs = driver.find_elements_by_xpath("//a[contains(@href,'tsv')]")
    hrefs = [href.text for href in hrefs]
    data.append(hrefs)



    # Get links to raw data.

    regex = re.compile("['a-z']*" + DATA_EXTENSION)
    hrefs = [page.find_all('a', href = regex) for page in soup]

    # Get links to meta data.
    regex = re.compile("meta" + META_EXTENSION)
    all_meta = [page.find_all('a', href = regex) for page in soup]
    # Remove empty elements.
    empty = [len(href)==0 for href in hrefs]
    buttons = [button for (button,empty) in zip(buttons,empty) if not empty]
    soup = [page for (page, empty) in zip(soup, empty) if not empty]
    hrefs = [href for (href, empty) in zip(hrefs,empty) if not empty]
    all_meta = [json for (json, empty) in zip(all_meta,empty) if not empty]
    # Get dataset names. Do this after removing buttons with no links!
    data_names = [button.text.split("\n")[-1] for button in buttons]

    # Convert hrefs to filenames urls--nested list comprehension.
    data_urls = [[BASEURL + link.get('href') for link in links] for links in hrefs]
    data_urls = [dict(zip(["ExprData"], [urls] )) for urls in data_urls]
    # Convert json to urls using nested list comprehension.
    meta_urls = [[BASEURL + link.get('href') for link in links] for links in all_meta]
    meta_urls = [dict(zip(["MetaData"], [urls] )) for urls in meta_urls]
    # Bind names, dataset urls, and json metadata urls as dict.
    datasets = dict(zip(data_names,list(zip(data_urls,meta_urls))))
    # Write to file.
    here = os.getcwd()
    root = os.path.dirname(here)
    now = str(date.today())
    datasets_json = json.dumps(datasets)
    myfile = os.path.join(root,"rdata",now + "_cell-datasets.json")
    f = open(myfile,"w")
    f.write(datasets_json)
    f.close()
    print(myfile, file=sys.stdout)
# EOF
    
if __name__ == '__main__':
    getDatasets()
