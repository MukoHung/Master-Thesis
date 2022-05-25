from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import time

def login(browser, account, password):
    browser.get("https://www.github.com/login")
    browser.find_element_by_id('login_field').send_keys(account)
    browser.find_element_by_id('password').send_keys(password)
    browser.find_element_by_name('commit').click()

def search_download(browser, search_page):
    url = "https://github.com/search?l=PowerShell&o=desc&q=microsoft+tool+ps1&s=indexed&type=Code&p="
    for page in range(search_page):
        try:
            url_page = url + str(page+1)
            browser.get(url_page)
            time.sleep(1)
            soup = BeautifulSoup(browser.page_source,'html.parser')
            link_list = soup.find_all('div', 'f4 text-normal')

            for n in link_list:
                title = n.a.get("title").replace('/','_')
                path = "https://github.com" + n.a.get('href')
                browser.get(path)
                time.sleep(2)
                browser.find_element_by_id('raw-url').click()
                res = BeautifulSoup(browser.page_source,'html.parser')
                open(".\\ps1\\"+title, 'wb').write(res.text.encode())
        except Exception as e:
            print(e)
            

if __name__ == '__main__':

    account = 'alice870103@gmail.com'
    password = ''
    search_page = 100

    options = Options()
    options.add_argument('--headless')
    browser = webdriver.Firefox()

    login(browser, account, password)
    time.sleep(15)
    search_download(browser, search_page)


