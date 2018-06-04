library(tidyverse)
library(rvest)

file_xpath <- read_html('xml.html')

# sintaxe do css selectors

file_xpath %>% html_nodes(css = '#inicio')
file_xpath %>% html_nodes(css = '.java')
file_xpath %>% html_nodes(css = 'p.java')

# Sintase do xpath

file_xpath %>% html_nodes(xpath = '//p[@class="java"]')
file_xpath %>% html_nodes(xpath = '//hour')
file_xpath %>% html_nodes(xpath = '//*[@id="inicio"]')