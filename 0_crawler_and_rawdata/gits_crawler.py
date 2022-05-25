# -*- coding: utf-8 -*-
import requests
from bs4 import BeautifulSoup
import pandas as pd
import numpy as np
from lxml import etree
import datetime
import time

def get_URL_list(total_page):
    for page in range(total_page):
        
        ps_list = {}

        params = (
            ('l', 'PowerShell'),
            ('q', 'ps1'),
            ('type', 'code'),
            ('p', str(page+1)),
        )

        res = requests.get('https://github.com/search', params=params)

        Soup = BeautifulSoup(res.text,'html.parser')
        link_list = Soup.find_all('div', 'f4 text-normal')

        for n in link_list:
            title = n.a.get("title").split('/')
            # ps_list[title[-1]] = "https://github.com" + n.a.get('href')
            new_url = "https://github.com" + n.a.get('href')
            response = requests.get(new_url)
            Soup = BeautifulSoup(response.text,'html.parser')
            raw_data = Soup.find(class_="d-flex py-1 py-md-0 flex-auto flex-order-1 flex-md-order-2 flex-sm-grow-0 flex-justify-between hide-sm hide-md")
            print(raw_data)
        time.sleep(1)

        for file in ps_list:
            download_ps1(file, ps_list[file])
            time.sleep(2)
            print("File ["+file+"] done.")
        print("Page ["+str(page+1)+"] done.")


def download_ps1(title, URL):
    try:
        url = URL
        res = requests.get(url)
        Soup = BeautifulSoup(res.text,'html.parser')
        file = Soup.find(class_="BtnGroup").a.get("href")
        print(file)
        link = "https://github.com"+file
        r = requests.get(link)
        open('.\\ps1-2\\'+title, 'wb').write(r.content)
    except Exception as e:
        print(e)


if __name__ == '__main__':
    get_URL_list(1)
    

