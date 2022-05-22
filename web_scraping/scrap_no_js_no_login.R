################################################################################
##                    WHAT WILL WE DO?                                        ##
##  1. Standard web scraping  commands in R                                   ##
##  2. Combining scrap with website API                                       ##
################################################################################

# Importing Libraries
suppressPackageStartupMessages({
  library(rvest)
  library(dplyr)
})

# set the work space to the main folder
setwd('web_scraping')

# get the html of the page
# in this task, we will scrap detik.com page
detik_html <- read_html("https://www.detik.com/")

# let's assume we want to get all "berita utama" data
berita_utama <- detik_html %>%
  html_element(".berita-utama") %>%
  html_elements(".media__title")

# create a dataframe about the news and the links
tit_link_berita_utama <- data.frame(title = berita_utama %>% html_text(), link = berita_utama %>% html_elements('a') %>%  html_attr('href'))

tit_link_berita_utama

# Instead of scraping the main page of the 'https://www.detik.com/',
# we can also scrape the specific page.
# For example, we want to scrape the most popular news
detik_popular_html <- read_html("https://www.detik.com/terpopuler")

# getting all the popular news by seraching the class of 'list-content__item
news_grid <-detik_popular_html %>%
  html_elements(".list-content__item")

# there are two interesting items here,
# first is the title of the news
# and the date of the news
# get the title along the link
tit_and_link <- news_grid %>%
  html_element('.media__title')

# get the date of the news
news_date <- news_grid %>%
  html_element('.media__date') %>%
  html_element('span') %>%
  html_attr('title')

# create the dataframe for the popular news
detik_popular_news <- data.frame(title = tit_and_link %>% html_text() %>% trimws(),
                                 date = news_date,
                                 link = tit_and_link %>% html_elements('a') %>%  html_attr('href'))
