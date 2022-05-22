################################################################################
##                    WHAT WILL WE DO?                                        ##
##  1. Standard web scraping  commands in R                                   ##
##  2. Website with API                                                       ##
##  3. Combining web scraping with website API                                ##
##  4. Scraping through all pages                                             ##
##  5. Parameterized API                                                      ##
##  6. Limiting Search by date using API when available                       ##
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

# what we do previously by directly visiting the specific webpage is known as API
# API (Application Programming Interface) is like a waitress that connects customer with the chef
# The `terpopuler` at the end of the link is usually known as endpoint
# Now, our next question when scraping news is that what if we need to search specific news?
# This is one of the use of the API.
# By using `search/searchall` endpoint, we can send the query to the website to search specific information
# Please note if each website may or may not set an API to communicate with.
# Each website also has their own endpoints list and rules to connect to their API
# Suppose we want to scrap all news about 'crypto' from detik.com
# the format of the website will be : `https://www.detik.com/search/searchall?query=crypto`
crypto_news_html <- read_html('https://www.detik.com/search/searchall?query=crypto')

# the news are put on class of `list media_rows list_berita`
crypto_news_list <- crypto_news_html %>%
  html_elements('.list,list_berita') %>%
  html_elements("a")

# the structure of the news tells us that the link is put on 'a' tag under article tags
# The text and date of the news put on class of box_text on a `span` tag under `a` and `article` tags
# that's why we directly access the `a` tag instead of article tag
# now, let's build the data frame
crypt_news_df <- data.frame(
  title = crypto_news_list %>% html_elements(".title") %>% html_text(),
  link = crypto_news_list %>% html_attr("href")
)

# getting the date
# Since there is a little bit problem when extracting the date, I use the following approaches
# tell me if you have the better one
# I have tried :not() to exclude span.category with no luck
date_news <- crypto_news_list %>% html_elements(".box_text>span.date") %>%
  html_text()

pattern_opts <- c("detikFinance", "detikInet", "detikHot", "detikNews", "detikHealth")
for (a in pattern_opts) {
  date_news <- date_news %>%
    gsub(pattern = a, replacement = "")
}
crypt_news_df$date <- date_news

# Now, the question is what if we want to scrape another news and we have bunch of lists?
# should we manually put them one by one?
# nope, we can now working automatically by combining our script using detik web API
# Suppose we want to scrape news regarding Etherium and Bitcoin
search_query <- c("Bitcoin", "Etherium")

# one thing to remember is that,
# no matter what the search query, we will always repeated those previous processes
# so, in order to follow DRY rules, we can make a function
get_news <- function(search_query, pattern_opt_out = c("detikFinance", "detikInet", "detikHot", "detikNews", "detikHealth")) {
  html_page <- read_html(paste0("https://www.detik.com/search/searchall?query=", search_query))

  news_list <- html_page %>%
    html_elements(".list,list_berita") %>%
    html_elements("a")

  news_df <- data.frame(
    title = news_list %>% html_elements(".title") %>% html_text(),
    link = news_list %>% html_attr("href")
  )

  date_news <- news_list %>%
    html_elements(".box_text>span.date") %>%
    html_text()

  for (opt in pattern_opt_out) {
    date_news <- date_news %>%
      gsub(pattern = opt, replacement = "")
  }
  news_df$date <- date_news
  return(news_df)
}

# the function is ready to use
# but, the problem is that the function only accept one search query for one execution, while we have two
# for this, I prefer using lapply as follow
list_news <- lapply(search_query, get_news) %>%
  bind_rows() # since the list has same dimension, they can be combined using bind_rows function

# If we take a look at the final data, we only have 18 news for two search queries
# If we search directly in the website, we have bunch of them
# what's the problem
# yes, `pagination`.
# we can scrap all the news for every page by using the following ways
# first, we need to know how many records found
all_res <- crypto_news_html %>%
  html_element("span.fl") %>%
  html_text2() %>%
  stringr::str_extract("\\d+") %>%
  as.numeric()

# now, get how many news in one pages
news_per_page <- crypto_news_html %>%
  html_elements('.list,list_berita') %>%
  html_elements("a") %>%
  length()

total_page <- ceiling(all_res/news_per_page)

# after knowing the page, we know can add the page to the search api as parameter
# the format is "https://www.detik.com/search/searchall?query=crypto&page=`page_number`"
# Our first task then is to create a page number sequence from 1 to total_page
all_page <- seq(total_page)
# Now, scrap each page
all_res <- all_page %>%
  lapply(FUN = function(i) {
    print(paste("scraping page no", i))
    query_search <- paste0("crypto&page=", i)
    get_news(query_search)
  }) %>%
  bind_rows()

# based on the new information, we need to modify our function so it will scrap all the news
get_news_all_pages <- function(search_query, pattern_opt_out = c("detikFinance", "detikInet", "detikHot", "detikNews", "detikHealth")) {
  html_page <- read_html(paste0("https://www.detik.com/search/searchall?query=", search_query))
  all_res <- html_page %>%
    html_element("span.fl") %>%
    html_text2() %>%
    stringr::str_extract("\\d+") %>%
    as.numeric()

  news_per_page <- html_page %>%
    html_elements('.list,list_berita') %>%
    html_elements("a") %>%
    length()

  total_page <- ceiling(all_res/news_per_page)
  all_page <- seq(total_page)
  print(paste0("there is ", total_page, " page(s) found."))
  all_res <- all_page %>%
    lapply(FUN = function(i) {
      print(paste("scraping page no", i))
      query_search <- paste0("crypto&page=", i)
      get_news(query_search)
    }) %>%
    bind_rows()
  return(all_res)
}

# In the previous format, query and page are usually known as parameter
# This is a typical example about how an API is parameterized
# Another parameters accepted by detik.com are fromdatex & todatex
# Both are used to limit the date of the news we are looking for
# The format of the date is dd/mm/yyyy
# Suppose we want to scrap news about crypto that comes from April 21st 2022 up to May 22nd 2022
# We can use the following query
get_news_all_pages("crypto&fromdatex=21/04/2021&todatex=22/05/2022")
