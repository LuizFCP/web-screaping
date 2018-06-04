library(tidyverse)
library(rvest) #Páginas html sem JS
#Forma mais rápida de fazer ctrlC ctrlV para machine learning
#Tag, Id, Classe

http://www.ssp.ba.gov.br/modules/consultas_externas/index.php?cod=5

url <- 'http://200.187.8.90/boletim-stelecom/?bo_cod=2990'

page <- read_html(url); page

page %>% 
  html_nodes('h1') %>% #Informar a tag
  html_text()

#Seletor, no site, fica num td as informações (conteúdo) #O cabeçalho em th

page %>% 
  html_nodes('td') %>%
  html_text()

#Todo o conte?do da tabela ta num bloco, um div, que é um table

page %>% 
  html_nodes('table') %>% #Observe que tem slots para cada tabela
  html_text()

page %>% 
  html_nodes('table') %>% 
  html_table() %>% #Função para extrair tabela
  .[[1]]

#Utiliza a classe para extrair, pegando no html

page %>% 
  html_nodes('.tabelaResultado') %>% #Necessário o . sempre
  html_table() %>% 
  .[[1]]

page %>% 
  html_nodes('#content-i') %>% 
  html_nodes('.tabelaResultado') %>% 
  html_table() %>% 
  .[[1]]


#html_nodes chamando apenas entre '' ta chamando a tag, com . ta chamando a classe e com # a id

#-------------------------------------------------------------

#Automatizando

url2 <- 'http://www.ssp.ba.gov.br/modules/consultas_externas/index.php?cod=5' 

page_base <- read_html(url2); page_base

page_base %>%  #Clicando no seletor e na página (div class=pagina)
  html_nodes('.paginas')

page_base %>% 
  html_nodes("a") %>% #classe
  html_text()

##

#url_number <- 2986

#url3 <- paste0('http://200.187.8.90/boletim-stelecom/?bo_cod=', url_number)

#page2 <- read_html(url3); page2

#names <- page2 %>% html_nodes('h1') %>% html_text(); names

#id_table <- which(names=="Veículos Roubados")

n_dias <- 3
tipo <- "Veículos Roubados"

#table <- page %>% 
#  html_nodes('table') %>% 
#  html_table() %>% 
#  .[[id_table]]

table <- c()

for(i in 0:n_dias){
  url_number <- 2986 - i
  
  url <- paste0('http://200.187.8.90/boletim-stelecom/?bo_cod=', url_number)
  
  page <- read_html(url)
  
  names <- page %>% html_nodes('h1') %>% html_text()
  
  id_table <- which(names=="Veículos Roubados") 
  
  table_i <- page %>% 
    html_nodes('table') %>% 
    html_table() %>% 
    .[[id_table]] 
  
  table <- rbind(table, table_i)
  
  print(i)
};head(table)


#-------------------------------------------

url <- 'https://stackoverflow.com/'

session <- html_session(url) #status200=acessado sem problema, tipo de enconding=utf-8, size=
session

#html_form(session) #Fórmulario html da page
#1- parâmetro 'q' onde faz a busca
#2- parâmetro 'fkey' onde entra o login

form <- html_form(session) #formulário vazio

filled_form <- form #salva o formulário vazio

filled_form[[1]] <- set_values(filled_form[[1]], #completar o formulário no slot 1
                               q = "r")

filled_form

session <- submit_form(session = session, #Submeter o formulário, como se vc mandasse apertar
                       form = filled_form[[1]])

session

question_id <- session %>% 
  html_nodes("div.question-summary") %>% 
  html_attr('id') #Atributos, que podem pode ser id, class ....

session %>%  #html_nodes(x, css, xpath) precisamos colocar css ou xpath
  html_nodes(xpath = '//*[@id="question-summary-50474784"]') %>%  #antes estavamos fazerndo por css, agora vamos por xpath (usado para xml)
  html_nodes('h3') %>% 
  html_text()

n_paginas <- 3

for (i in 1:3) {
  
  url_busca <- paste0('https://stackoverflow.com/questions/tagged/r?page=',i,'&sort=newest&pagesize=15') #apaga o 2 (da segunda página) e coloca "i"
  
  session <- session %>% jump_to(url_busca)
  
  id_question <- session %>% 
    html_nodes("div.question-summary") %>% 
    html_attr('id')
  
  for (j in 1:length(id_question)) {
    
    xpath_i = paste0('//*[@id=','"',id_question[j],'"]') #'"' pois na id do xpath precisa entrar aspas (")
    
    session %>%  
      html_nodes(xpath = xpath_i) %>%  
      html_nodes('h3') %>% 
      html_text()
    
    session <- session %>% follow_link(pergunta)
    
    texto_pergunta <- session %>% 
      html_node('div.post-text') %>% 
      html_nodes('p') %>% 
      html_text() %>% 
      paste(collapse = '')
    
    session <- session %>% back()
    
    Sys.sleep(3) #Argumento em segundos
    
  }
  
}
