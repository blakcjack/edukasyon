# Web Scraping Using R

In order to scrap a website in R, we can use `rvest` library. Based on how to access the web, there are two types of website, first web with no authentication such as news website and second the web that requires us to log in. Based on how the content is published, there are two types of website too, first web with no java script control and the second is web with java script control.

For web that requires log in, we need to authenticate ourself first before scraping any data. Usually, it is difficult and illegal to scrap this type of website unless they provide us a legal API to scrap it out. If there is no API provided, we usually need `RSelenium` to handle the login and logout process. 

For web that is mostly controlled by java script, we also need the `RSelenium` to help handling the scraping process.

# Basic Scraping Flow

Basically, the scraping flow using `rvest` will follow these steps:

1. Get the HTML page by using `read_html(url)` function.
2. Get either the nodes or elements value using `html_nodes()` or `html_elements()`.
3. Access the value by using `html_text()` or `html_attr()` function.

If we use `RSelenium` to scrap the web, we usually follow the following steps:

1. Create the server and client using `rsDriver()`
2. Access the method `naviaget()` and pass the url you are interested to.
3. Access each elements you are interested in using method `findElement()` or `findElements()` for multiple elements.
4. You can get the value using `getElementText()` function.

If the website require us to manual login, we can use the RSelenium with the following steps:

1. Create the server and client using `rsDriver()`
2. Access the method `naviaget()` and pass the url you are interested to.
3. Access the element to input the username and password by using method `findElement()`. Ensure that we have one input field for one object. We can save them in variables.
4. From the variables, we can use method `sendKeysToElement()` to send the username and password.
5. Access the button login and use method `clickElement()` to click it.
6. If the username and password is correct, we will logged in to the web.

# `rvest` in Brief

`rvest` is a package created by well known R developer, Hadley Wickham. In python this package is identical to `Beautifulsoup`, except the OOP of course. The `rvest` package uses R functional programming concept. It means the function is not integrated into the object.

Some basic functions widely used in basic scraping are as follow:

- `read_html()` to read a web page and fetch them as html.
- `html_node()`, `html_node()` are two functions to fetch the node of the html. We can use xpath or css selectors. These functions are superseeded.
- `html_ement()` and `html_elements()` are the current recommended function to get an html element using xpath or css selectors. These functions are the newly developed functions from `xml_node()`, `xml_nodes()`, `html_node()`, and `html_nodes()`.
- `html_text()` and `html_text2()` are two functions that will extract text value from our element.
- `html_attr()` and `html_attrs()` are used to extract specific information from specific html attributes.

# `RSelenium` in Brief

`RSelenium` is a library created by John Harrison. This package is specifically made to help us interactively communicate with a website using script. In other words, we are creating a robot to communicate with a website. Unlike `rvest`, `RSelenium` was made under fully OOP concept. The main object that will be used massively is `remoteDriver` object.

# What is XPath and CSS Selector?

When scraping the websites, we will often find nodes/elements of an html page. To get the nodes/elements, we have two options, first using the css selector or using the xpath. Both of them can be inspected by using inspect function from our favorite browser. Both are like pointer that will tell our program to specifically select and or process the selected nodes/elements that is pointed by the css selector or the xpath.

For example, if we want to find all the elements of an html with tag `a`, then we can write `html_elements(html_page, "a")`. If then, we want to search all the element of class of `object1`, then we write `html_elements(html_page, "object1")`. Those are css selector.

Not only using the css selectors, we can also use the xpath to search one or more elements. For detail reference about xpath, you can visit the [following link](https://en.wikipedia.org/wiki/XPath).
