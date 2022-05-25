# -*- coding: utf-8 -*-
import requests
from bs4 import BeautifulSoup
import pandas as pd
import numpy as np
import datetime
import time

def PhishTank_Search(page, valid, url='https://gist.github.com/search?l=PowerShell&o=desc&q=ps1&s=stars'):
    if (page): # 如果有輸入頁數
        page = str(page)
        url = url + '&page=' + page
        print('query page: ',page)
    if (str(valid) == 'y' or str(valid) == 'n'): # 若有指定valid條件
        url = url + '&valid=' + str(valid)
    
    response = requests.get(url)
    if (response.status_code == 429):
        print("page= ", page)
        print("response.status_code:",response.status_code)
    else:
        return response

def find_IDs(valid, page=0, url='https://www.phishtank.com/phish_search.php?Search=Search'):
    response = PhishTank_Search(page, valid, url=url)
    if ( not response):
        return False
    soup_text = BeautifulSoup(response.text, 'html.parser')
    soup_trs = soup_text.find_all('tr')
    tr_len = len(soup_trs)
#     print('tr_len: ',tr_len)
    phishIDs = list()
    for i in range(1,tr_len): # 第0個 是欄位說明        
        phishIDs.append( soup_trs[i].find_all('td')[0].get_text() )
    return phishIDs

def getURL_byIDs(IDs_list, url='https://www.phishtank.com/phish_detail.php'):
    ID_URL_dict = dict()
    for i in range(0, len(IDs_list)):
        ID = IDs_list[i]
        url_ID = url + '?phish_id=' + ID
        response = requests.get(url_ID)
        if ( response.status_code != 200 ):
            print("ID= ", ID)
            print("response.status_code:",response.status_code)
            return False
        else:
            soup_text = BeautifulSoup(response.text, 'html.parser')
            target_url = soup_text.find('span', style='word-wrap:break-word;').find('b').get_text()
            ID_URL_dict[ID] = target_url
#             print(ID_URL_dict)
        time.sleep(0.5)
    return ID_URL_dict

# test = find_IDs('y')
# print(test[:5])
# test_dict = getURL_byIDs(test)

'''Main Code'''

'''Phish Parse'''
page = 2
ID_URL_dict = dict()
for i in range(0,page):
    IDs_list = find_IDs('y',page=i) # Phish
    ID_URL_dict.update( getURL_byIDs(IDs_list) )

print(len(ID_URL_dict))

IDs_list = list()
URLs_list = list()
for key, value in ID_URL_dict.items():
    IDs_list.append(key)
    URLs_list.append(value)

Phish_ID_URL_pd = pd.DataFrame({"ID":IDs_list, "URL":URLs_list })
print(Phish_ID_URL_pd.info())
print(Phish_ID_URL_pd.head())

result = time.localtime()
time_str = str(result.tm_year) + '-' + str(result.tm_mon) + '-' + str(result.tm_mday) + '-' + str(result.tm_hour) + '-' + str(result.tm_min)

Phish_ID_URL_pd.to_csv("Phish_ID_URL_pd_"+ time_str +".csv")

'''NoPhish Parse'''
page = 2
ID_URL_dict = dict()
for i in range(0,page):
    IDs_list = find_IDs('n',page=i) #NoPhish
    ID_URL_dict.update( getURL_byIDs(IDs_list) )
    
print(len(ID_URL_dict))

IDs_list = list()
URLs_list = list()
for key, value in ID_URL_dict.items():
    IDs_list.append(key)
    URLs_list.append(value)

NoPhish_ID_URL_pd = pd.DataFrame({"ID":IDs_list, "URL":URLs_list })
print(NoPhish_ID_URL_pd.info())
print(NoPhish_ID_URL_pd.head())

result = time.localtime()
time_str = str(result.tm_year) + '-' + str(result.tm_mon) + '-' + str(result.tm_mday) + '-' + str(result.tm_hour) + '-' + str(result.tm_min)

NoPhish_ID_URL_pd.to_csv("NoPhish_ID_URL_pd_"+ time_str +".csv")

