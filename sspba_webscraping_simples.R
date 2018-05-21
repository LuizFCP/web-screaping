# Webscraping - Site da Secretária de segurança pública da Bahia

library(tidyverse)
library(rvest)

#2 funções node e nodes
#node ele retorna o primeiro elemento do que você está buscando (retorna apenas 1 elementos)
#nodes ela retorna tudo

# Level 1: Raspando tabela de veiculos roubados do dia anterior

# Acessar o site - http://www.ssp.ba.gov.br/modules/consultas_externas/index.php?cod=5
# Copiar link de uma das urls disponíveis

url  <- 'http://200.187.8.90/boletim-stelecom/?bo_cod=2986'

page <- read_html(url)

#conteúdo do site ta no <body>

# Visualizando de forma geral o HTML extraido

#Selenium (entra em ação caso tenha javascript) acessa a pagina depois do javascript estiver carregado
#O que muda da linha 13 é ter java script ou não, função read_html

page %>% 
  html_text() #Acessar o site e baixa o html 

#Não vem estruturado, problema

#perceber a tag (no caso h1)

# Extraindo o título das tabelas

table_names <- page %>% 
  html_nodes('h1') %>%  #coração do rvest (extraiu completamente a informação da estrutura h1)
  html_text() #vejo a natureza da informação, no caso texto, logo html_text

# Extraindo contéudo das tabelas - parte 1

table_ssp <- page %>% 
  html_nodes('td') %>% 
  html_text() #mt td, repara

# Extraindo contéudo das tabelas - parte 2

table_ssp <- page %>%      #todas as tabelas da page
  html_nodes('table') %>%             # 'tag'
  html_table() %>%  #tabelas vem separadas em slots de listas (estruturei o que não estava estruturado)
  .[[1]]

#?help_nodes
#X é a pagina html, CSS é o seletor de css que estamos escolhendo (passa o mouse em cima, o seletor coincide com o do html, no caso h1 ...)

#div é um bloco onde coloca dados(tag) dentro

# Sobre a sintaxe do 'html_nodes' 
#retirando a mesma informação de jeitos diferentes, sendo mais específico

table_ssp <- page %>% 
  html_nodes('table') %>%             # 'tag'
  html_table() 

page %>% 
  html_nodes('.tabelaResultado') %>%   # '.class'   eu posso extrair a tabela pela class, preciso colcoar .class 
  html_table()


page %>% 
  html_nodes('#content-i') %>%         # '#id'   deixar o alvo específico
  html_nodes('.tabelaResultado') %>%   # '.class'
  html_table()

# Ainda não construímos um screaper, screaper seria a automatização da raspagem
# Saber ter a manha de construir um screaper bom, pois pode acabar derrubando uma página ous endo bloqueado pelo IP, logo importante IP dinâmico (caso faça algo pesado)

# ao usar html_nodes('table') pode acontecer de retornar nada (0)
# no caso usar html_nodes('*') vai retornar todas as tags, caso perceba alguma tag script, isso é javaScript
# não pode usar mais o rvest, pelo menos para a extração, aí entra o R Selenium

