################################################################################
##                    WHAT WILL WE DO?                                        ##
##  1. Log in to a website using `RSelenium`                                  ##
################################################################################

# to scrap the website that needs login,
# we can use `RSelenium`
# You can follow the following steps
# Please note: For some websites, scraping information from their websites
# might be prohibited, so DWYOR.

# import needed library
suppressPackageStartupMessages({
  library(RSelenium)
  library(dplyr)
})

# Create the server and the client, we call it remote driver
rD <- rsDriver(browser = "firefox", port = 5449L)

# We need the client to work with
remDClient <- rD[['client']]

# since we now have the object of remDClient
# we can do anything with our browser, through our script.
# our remDClient is an Object with various methods
# unlike R conventional system, in order to ask the object to do something,
# we need to access the methods.
# in order to know all the methods, type `?remoteDriver` in your console
# now, the first method to access is `navigate()`
remDClient$navigate("https://www.facebook.com")

# our browser client will show us the page we are visiting
# now, we can use xpath to get the path of the login input
# both username and password
# we need to save the current object to a variable, since to interact with we
# again need to access the methods.
input_username <- remDClient$findElement(using = 'xpath', value = '//*[@id="email"]')
input_password <- remDClient$findElement(using = "xpath", value = '//*[@id="pass"]')
login_button <- remDClient$findElement(using = 'xpath', value = '//*[@id="u_0_d_89"]')
# to input our username, we can use `sendKeysToElement` method
input_username$sendKeysToElement(list("Suberlin Sinagas")) # put your username
input_password$sendKeysToElement(list("")) # put your password
# now click the login button by using `clickElement` method
login_button$clickElement()

# if the username and password are correct you will automatically be logged in
# to scrap the web using RSelenium, read the code in another documents.
