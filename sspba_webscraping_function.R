# Criando um WebScraper - Site da Secretária de segurança pública da Bahia

library(tidyverse)
library(rvest)

url_base <- 'http://www.ssp.ba.gov.br/modules/consultas_externas/index.php?cod=5'

page_base <- read_html(url_base)

# O problema do Java-Script

page_base %>% 
  html_nodes('.paginas')  # {xml_nodeset (0)}

page_base %>% html_nodes('.ext-2') %>% html_text()

# Contornando a barreira de java-script

url_number <- 2986

url <- paste0('http://200.187.8.90/boletim-stelecom/?bo_cod=',url_number) #automatiza - junta url com o número da página, isso automatiza a criação dos links pra contornar o java

page <- read_html(url)

names <- page %>% html_nodes('h1') %>% html_text()

id_table <- which(names == "Veículos Roubados") #fornece o número da tabela, nesse caso a segunda tabela

table <- page %>% html_nodes('table') %>% html_table() %>% .[[id_table]] #

# TOrnando a busca entre páginas automática

n_paginas <- 20

table <- c()

for (i in 0:n_paginas) {
  
  url_number <- 2986 - i
  
  url <- paste0('http://200.187.8.90/boletim-stelecom/?bo_cod=',url_number)
  
  page <- read_html(url)
  
  names <- page %>% html_nodes('h1') %>% html_text()
  
  id_table <- which(names == "Veículos Roubados")
  
  table_i <- page %>% html_nodes('table') %>% html_table() %>% .[[id_table]]
  
  table <- rbind(table, table_i)
  
}

# Testando uma página vazia
# Apresenta como automatizar

url_number <- 2979

url <- paste0('http://200.187.8.90/boletim-stelecom/?bo_cod=',url_number)

page <- read_html(url)

names <- page %>% html_nodes('h1') %>% html_text()

id_table <- which(names == "Veículos Roubados")

table_i <- page %>% html_nodes('table') %>% html_table() %>% .[[id_table]]

# Lidando com páginas vazias
# Apresenta como extrair de várias tabelas

n_paginas <- 20

table <- c()

for (i in 0:n_paginas) {
  
  url_number <- 2986 - i
  
  url <- paste0('http://200.187.8.90/boletim-stelecom/?bo_cod=',url_number)
  
  page <- read_html(url)
  
  names <- page %>% html_nodes('h1') %>% html_text()
  
  if (!identical(names, character(0)) ) { #condição para tirar página vazias (em names retorna character(0)) - identical é como se fosse um == mas não tem == para character(0)
    
    id_table <- which(names == "Veículos Roubados")
    
    table_i <- page %>% html_nodes('table') %>% html_table() %>% .[[id_table]]
    
    table <- rbind(table, table_i)
    
  }
  
  print(i)
  
}

# Consolidando em uma função

ssp_scraper <- function(n_paginas, tipo = "Veículos Roubados"){
  
  table <- c()
  
  # Identificando url mais recente
  
  url_number_0 <- 2984
  
  dia <- Sys.Date() + 1
  
  hoje <- Sys.Date() - 1
  
  j <- 0
  
  while(dia != hoje){
    
    url_number_j <- url_number_0 + j
    
    url_j <- paste0('http://200.187.8.90/boletim-stelecom/?bo_cod=',url_number_j)
    
    page_j <- read_html(url_j)
    
    names_j <- page_j %>% html_nodes('h1') %>% html_text()
    
    if (!identical(names_j, character(0)) ) {
      
      id_table_j <- which(names_j == tipo)
      
      table_j <- page_j %>% html_nodes('table') %>% html_table() %>% .[[id_table_j]]
      
    }
    
    dia <- as.Date(table_j$`DATA E HORA`[1], format = '%d/%m/%Y %H:%M')
    
    url_number <- url_number_j
    
    j <- j + 1
    
  }
  
  
  for (i in 0:n_paginas) {
    
    url_number <- url_number - i
    
    url <- paste0('http://200.187.8.90/boletim-stelecom/?bo_cod=',url_number)
    
    page <- read_html(url)
    
    names <- page %>% html_nodes('h1') %>% html_text()
    
    if (!identical(names, character(0)) ) {
      
      id_table <- which(names == "Veículos Roubados")
      
      table_i <- page %>% html_nodes('table') %>% html_table() %>% .[[id_table]]
      
      table <- rbind(table, table_i)
      
    }
    
    print(i)
    
  }
  
  return(table)
  
}

#ideia é buscar as tabelas até o dia atual e salvar a url e depois retornar ir acessando do dia mais atual até a informada em n_paginas

data_raw <- ssp_scraper(n_paginas = 20)

# Validação gráfica dos dados raspados

data_raw %>% 
  mutate(dia = as.Date(`DATA E HORA`, format = '%d/%m/%Y')) %>% 
  group_by(dia) %>% 
  dplyr::count() %>% 
  ggplot(aes(x = dia, y = n)) + 
  geom_line()

data_raw %>% 
  mutate(dia = as.Date(`DATA E HORA`, format = '%d/%m/%Y')) %>% 
  group_by(dia) %>% 
  dplyr::count() %>% 
  filter(dia > '2018-01-01') %>% 
  ggplot(aes(x = dia, y = n)) + 
  geom_line() + geom_point()

data_raw %>% 
  group_by(MARCA) %>% 
  count() %>% 
  ggplot(aes(x = MARCA)) +
  geom_bar(aes(y = n), stat = 'identity') + 
  coord_flip()

data_raw %>% 
  mutate(hora = as.factor(substr(`DATA E HORA`, 12,13))) %>% 
  group_by(hora) %>% 
  count() %>% 
  ggplot(aes(x = hora)) +
  geom_bar(aes(y = n), stat = 'identity') 