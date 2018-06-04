  # Navegando como em webbrowser - StackOverflow

library(tidyverse)
library(rvest)

# Conectando à página e preenchendo formulário

url <- 'https://stackoverflow.com'

session <- html_session(url)

form <- html_form(session)

filled_form <- form

filled_form[[1]] <- set_values(filled_form[[1]], q = "R")

session <-  submit_form(session = session, form = filled_form[[1]])

# Perguntas da pagina

question_id <- session %>% 
  html_nodes("div.question-summary") %>% 
  html_attr('id')

# Upvotes

session %>% 
  html_nodes(xpath = '//*[@id="question-summary-50427710"]') %>% 
  html_nodes('div.votes') %>% 
  html_nodes('span.vote-count-post') %>% 
  html_text() %>% 
  as.numeric()

# Resposta

session %>% 
  html_nodes(xpath = '//*[@id="question-summary-50427710"]') %>% 
  html_node('div.status.unanswered') %>% 
  html_nodes('strong') %>% 
  html_text()


session %>% 
  html_nodes(xpath = '//*[@id="question-summary-50427710"]') %>% 
  html_node('div.status.answered') %>% 
  html_nodes('strong') %>% 
  html_text() %>% 
  as.numeric()


# Tags

session %>% 
  html_nodes(xpath = '//*[@id="question-summary-50427710"]/div[2]/div[2]') %>% 
  html_nodes("a") %>% 
  html_text()

# Título da pergunta

question <- session %>% 
  html_nodes(xpath = '//*[@id="question-summary-50427710"]') %>% 
  html_nodes('h3') %>% 
  html_text()

# Link da pergunta

session %>% 
  html_nodes(xpath = '//*[@id="question-summary-50427710"]') %>% 
  html_nodes('h3') %>% 
  html_nodes('a') %>% 
  html_attr('href')

# Usuário 

session %>% 
  html_nodes(xpath = '//*[@id="question-summary-50427710"]') %>% 
  html_nodes('div.user-details') %>% 
  html_node("a") %>% 
  html_text()

session <- session %>% 
  follow_link(question)

session %>% 
  html_node("div.post-text") %>% 
  html_nodes('p') %>% 
  html_text() %>% 
  paste(collapse = '')
  
session <- session %>% back()

next_page <- session %>% 
  html_nodes('div.pager.fl') %>% html_nodes("a") %>% html_attr('href') %>% .[[1]]

session <- session %>% jump_to(next_page)