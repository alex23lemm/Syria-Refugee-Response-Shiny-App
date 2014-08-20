library(jsonlite)
library(dplyr)



get_country_data <- function(url) {
  
  raw_data <- fromJSON(url)
  
  people_of_concern <- sapply(raw_data$population, 
                              function(e) e[["value"]][1] %>% as.numeric)
  registered_syrian_refugees <- sapply(raw_data$population, 
                                       function(e) e[["value"]][2] %>% as.numeric)
  persons_awaiting_registration <- sapply(raw_data$population,
                                          function(e) e[["value"]][3] %>% as.numeric)
  demography <- sapply(raw_data$population,
                       function(e) unlist(e[['demography']][2, ])) %>%
    t %>%  apply(2, as.numeric) %>%
      
  processed_data <- raw_data %>% 
    select(name, latitude, longitude) %>%
    mutate(
      latitude = as.numeric(latitude),
      longitude = as.numeric(longitude),
      people_of_concern,
      registered_syrian_refugees,
      persons_awaiting_registration
    ) 
  
  processed_data <- cbind(processed_data, demography)
      
  return(processed_data)
  
}


get_regional_data <- function(url) {
  
  raw_data <- fromJSON(url)
  
  people_of_concern <- sapply(raw_data$population, 
                              function(e) e[["value"]][1] %>% as.numeric)
  registered_syrian_refugees <- sapply(raw_data$population, 
                                       function(e) e[["value"]][2] %>% as.numeric)
  persons_awaiting_registration <- sapply(raw_data$population,
                                          function(e) e[["value"]][3] %>% as.numeric)
  
  processed_data <- raw_data %>% 
    select(country, name, latitude, longitude) %>%
    mutate(
      latitude = as.numeric(latitude),
      longitude = as.numeric(longitude),
      people_of_concern,
      registered_syrian_refugees,
      persons_awaiting_registration
    ) %>% 
    filter(country != name)
  
  return(processed_data)
}
