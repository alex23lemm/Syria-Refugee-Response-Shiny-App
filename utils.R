# Load libraries ---------------------------------------------------------------

library(jsonlite)
library(dplyr)
library(tidyr)
library(ggplot2)
library(RColorBrewer)


# Define functions -------------------------------------------------------------

get_UNHCR_population_data <- function(url, regions = FALSE) {
  
  raw_data <- fromJSON(url)
  
  people_of_concern <- sapply(raw_data$population, 
                              function(e) e[["value"]][1] %>% as.numeric)
  registered_syrian_refugees <- sapply(raw_data$population, 
                                       function(e) e[["value"]][2] %>% as.numeric)
  persons_awaiting_registration <- sapply(raw_data$population,
                                          function(e) e[["value"]][3] %>% as.numeric)
  
  # There seems to be a bug in the UNHCR data retrieval process for country data
  # Although just one row should be included, in total 2 records are returned 
  # whereas the first one just includes NAs. Retrieval of regional data works
  # as expected
  row_index <- ifelse(regions, 1, 2)
  
  demography <- sapply(raw_data$population,
                       function(e) unlist(e[['demography']][row_index, ])) %>%
    t %>%  apply(2, as.numeric)
      
  processed_data <- raw_data %>% 
    select(if(regions) country, name, latitude, longitude) %>%
    mutate(
      latitude = as.numeric(latitude),
      longitude = as.numeric(longitude),
      people_of_concern,
      registered_syrian_refugees,
      persons_awaiting_registration
    ) 
  
  processed_data <- cbind(processed_data, demography)
  
  if(regions)
    processed_data <- filter(processed_data, country != name)
     
  return(processed_data) 
}



tidy_demographic_data <- function(demographic_data) {
  
  demographic_data <- demographic_data %>% 
    select(name, ends_with('M'), ends_with('F')) %>%
    gather(age, numb_of_persons, -name) %>% 
    separate(age, into = c('age', 'gender'), sep = -2) %>%
    group_by(name) %>%
    mutate(
      percent = round(numb_of_persons / sum(numb_of_persons) * 100, digits = 1)
    ) %>% 
    ungroup %>%
    mutate(
      age = factor(age, levels = c('04', '511', '1217', '1859', '60'),
                   labels = c('0-4', '5-11', '12-17', '18-59', '60+'))
    )
  
  return(demographic_data)
}


create_pyramid_plot <- function(demographic_data, country_name) {
  
  demographic_data <- demographic_data %>% filter(name == country_name)
  
  g <- ggplot(demographic_data, aes(age, percent, fill = gender)) +
    geom_bar(data = filter(demographic_data, gender == 'M'), stat = 'identity') +
    geom_bar(aes(y = percent * -1), filter(demographic_data, gender == 'F'), 
             stat = 'identity') +
    geom_text(aes(label = percent), filter(demographic_data, gender == 'M')) +
    geom_text(aes(label = percent, y = percent * -1), filter(demographic_data, 
                                                             gender == 'F')) +
    coord_flip() +
    theme_bw() +
    scale_fill_brewer(palette = 'Set1')
  
  return(g)
}


