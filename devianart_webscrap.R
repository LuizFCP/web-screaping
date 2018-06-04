library(tidyverse)
library(rvest) #P?ginas html sem JS
#Forma mais rápida de fazer ctrlC ctrlV para machine learning

url <- "https://www.deviantart.com"


# Levantamento dos valores para o formulário

page <- read_html(url)

session <- html_session(url)

form <- html_form(session)

filled_form <- form

filled_form[[1]] <- set_values(filled_form[[1]], q = "avengers")

session <- submit_form(session = session,
            form = filled_form[[1]]) %>% follow_link('whats-hot')

nodes <- session %>% 
  html_nodes("*")

imagens <- session %>% 
  html_nodes(xpath = '//img') %>% 
  html_attr('src') %>% as.data.frame()

//*[@id="page-1-results"]/span[3]/a/img