from crawl_article_util import *
import sys

if __name__ == "__main__":
    print('start crawling')
    
    num = int(sys.argv[1])
    run_crawl(num, num)

