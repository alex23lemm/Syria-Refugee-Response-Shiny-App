library(jsonlite)
library(dplyr)


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
