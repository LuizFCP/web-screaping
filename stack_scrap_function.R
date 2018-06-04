# Navegando como em webbrowser - StackOverflow

library(tidyverse)
library(rvest)

sof_scraper <- function(n, search){
  
  results <- c()
  
  # Conexão e preenchimento de formulário
  
  url <- 'https://stackoverflow.com'
  
  session <- html_session(url)
  
  form <- html_form(session)
  
  filled_form <- form
  
  filled_form[[1]] <- set_values(filled_form[[1]], q = search)
  
  session <-  submit_form(session = session, form = filled_form[[1]])
  
  for (i in 1:n) {
    
    next_page_link <- paste0('/questions/tagged/r?page=',i,'&sort=newest&pagesize=15')
    
    session <- session %>% jump_to(next_page_link)
    
    # Perguntas da pagina
    
    question_id <- session %>% 
      html_nodes("div.question-summary") %>% 
      html_attr('id')
    
    for (j in 1:length(question_id)) {
      
      xpath_id <- paste0('//*[@id="', question_id[[j]], '"]')
      
      # Título da pergunta
      
      question <- session %>% 
        html_nodes(xpath = xpath_id) %>% 
        html_nodes('h3') %>% 
        html_text()
      
      # Link da pergunta
      
      link <- session %>% 
        html_nodes(xpath = xpath_id) %>% 
        html_nodes('h3') %>% 
        html_nodes('a') %>% 
        html_attr('href')
      
      # Votos
      
      votes <- session %>% 
        html_nodes(xpath = xpath_id) %>% 
        html_nodes('div.votes') %>% 
        html_nodes('span.vote-count-post') %>% 
        html_text() %>% 
        as.numeric()
      
      # Tags
      
      tags <- session %>% 
        html_nodes(xpath = paste0(xpath_id,'/div[2]/div[2]')) %>% 
        html_nodes("a") %>% 
        html_text()
      
      # Usuário 
      
      user <- session %>% 
        html_nodes(xpath = xpath_id) %>% 
        html_nodes('div.user-details') %>% 
        html_node("a") %>% 
        html_text()
      
      # Acessar texto da pergunta
      
      session <- session %>% 
        follow_link(question)
      
      text <- session %>% 
        html_node("div.post-text") %>% 
        html_nodes('p') %>% 
        html_text() %>% 
        paste(collapse = '')
      
      session <- session %>% back()
      
      # Consolidação dos dados raspados
      
      results_j <- data.frame(pergunta = question,
                              usuario = user,
                              votos = votes,
                              texto = text,
                              Tag1 = NA,
                              Tag2 = NA,
                              Tag3 = NA)
      
      
      results_j[1, c("Tag1", "Tag2", "Tag3")] <- tags[1:3]
      
      results <- rbind(results, results_j)
      
      Sys.sleep(3)
      
    }
    
    
    
  }
  
  return(results)
} 

dados <- sof_scraper(n = 1, search = 'r')

# Text Mining

library(wordcloud)
library(tm)

docs <- Corpus(VectorSource(paste(dados$texto, collapse = ''))) %>% 
  tm_map(content_transformer(tolower)) %>% 
  tm_map(removeNumbers) %>% 
  tm_map(removeWords, stopwords("english")) %>% 
  tm_map(removePunctuation) %>% 
  tm_map(removeWords, c("want")) %>% 
  tm_map(removePunctuation) %>% 
  tm_map(stripWhitespace)

dtm <- TermDocumentMatrix(docs)

m <- as.matrix(dtm)
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)

set.seed(1234)
wordcloud(words = d$word, freq = d$freq, min.freq = 1,
          max.words=200, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"))

# Frequência de temas

tags_all <- data.frame(tags = c(dados$Tag1, dados$Tag2, dados$Tag3))

tags_all %>% 
  group_by(tags) %>% 
  count() %>%
  filter(tags != 'NA', tags != 'r') %>% 
  ggplot(aes(x = tags, y = n)) + 
  geom_bar(stat = 'identity') +
  coord_flip()

