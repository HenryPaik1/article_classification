from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
import sys
import pickle
import time

url_ls = ['https://news.naver.com/main/main.nhn?mode=LSD&mid=shm&sid1=100',
         'https://news.naver.com/main/main.nhn?mode=LSD&mid=shm&sid1=101',
         'https://news.naver.com/main/main.nhn?mode=LSD&mid=shm&sid1=102',
         'https://news.naver.com/main/main.nhn?mode=LSD&mid=shm&sid1=103',
         'https://news.naver.com/main/main.nhn?mode=LSD&mid=shm&sid1=104',
         'https://news.naver.com/main/main.nhn?mode=LSD&mid=shm&sid1=105']
cat_ls = ['정치', '경제','사회','생활문화','세계','IT과학']

article_ls = list()

options = webdriver.ChromeOptions()
options.add_argument('--disable-notification')
options.add_argument('headless')
#driver = webdriver.Chrome(options=options)
driver = webdriver.Chrome('/home/ubuntu/chromedriver', options=options)

def crawl_cluster():
    s = '#main_content > div > div._persist > div:nth-child(1) .cluster_text > a'
    wait = WebDriverWait(driver, 5).until(EC.presence_of_all_elements_located((By.CSS_SELECTOR, s)))
    a = driver.find_elements_by_css_selector(s)
    for elem in a:
        article_ls.append(elem.text)

def crawl_page():
    s = '//*[@id="section_body"]/ul/li/dl/dt[2]/a'
    wait = WebDriverWait(driver, 5).until(EC.presence_of_all_elements_located((By.XPATH, s)))
    a = driver.find_elements_by_xpath(s)
    for elem in a:
        article_ls.append(elem.text)
        
def run_crawl(url_num, cat_num):
    url = url_ls[url_num]
    
    flag = False
    for i in range(2, 100):
    #for i in range(2, 3):
        if not flag:
            print('phase 1')
            driver.get(url)
            time.sleep(2)
            crawl_cluster()
            crawl_cluster()
            flag = True
        try:
            print('phase', i)
            time.sleep(1)    
            sub_url = url + '#&date=%2000:00:00&page={}'.format(i)
            driver.get(sub_url)
            crawl_page()
            print(len(article_ls))
        except:
            break

    with open('a_ls_{}.pickle'.format(cat_ls[cat_num]), 'wb') as f:
        pickle.dump(article_ls, f)
    
    driver.quit()
