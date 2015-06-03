# Load libraries ---------------------------------------------------------------

library(jsonlite)
library(httr)
library(plyr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(RColorBrewer)


# Define functions -------------------------------------------------------------

get_UNHCR_population_data <- function(url, regions = FALSE) {
  
  raw_data <- fromJSON(url)
  
  # Always exclude the general North Africa record because it does not provide
  # any summary statistic
  raw_data <- raw_data %>% filter(name != 'North Africa')
  
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
                       function(e) e[['demography']][row_index, ]) 
  
  # Make code more robut because demographic data might not be provided for 
  # every region
  placeholder <- data.frame(matrix(data = rep(NA, 10), ncol = 10))
  names(placeholder) <- c("04M",  "04F",  "511M",  "511F", "1217M", "1217F",
                          "1859M",  "1859F",  "60M",  "60F")
  
  for(i in seq_along(demography)) {
    if(is.null(demography[[i]]))
      demography[[i]] <- placeholder
  }
  
  demography <- rbind.fill(demography) %>% colwise(as.numeric)(.)
  
  processed_data <- raw_data %>% 
    select(if(regions) country, name, latitude, longitude) %>%
    mutate(
      latitude = as.numeric(latitude),
      longitude = as.numeric(longitude),
      people_of_concern,
      registered_syrian_refugees,
      persons_awaiting_registration,
      radius = round(people_of_concern / sum(people_of_concern) * 600000)
    ) 
  
  processed_data <- cbind(processed_data, demography)
  
  if(regions) {
    processed_data <- filter(processed_data, country != name)
  }
  
  summary_data <- data.frame(name="Entire Region", 
                             t(colSums(processed_data[,-1], na.rm = TRUE)),
                                        stringsAsFactors = FALSE)
  names(summary_data) <- names(processed_data)
  summary_data$latitude <- NA
  summary_data$longitude <- NA
  
  processed_data <- rbind(processed_data, summary_data)

     
  return(processed_data) 
}


tidy_demographic_data <- function(processed_population_data) {
  
  demographic_data <- processed_population_data %>% 
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
  
  y_max <- max(demographic_data$percent) %>% round_any(10, f = ceiling)
  
  g <- try(
    ggplot(demographic_data, aes(age, percent, fill = gender)) +
    geom_bar(data = filter(demographic_data, gender == 'M'), stat = 'identity',
             width = 0.6, position = position_dodge(width = 0.5)) +
    geom_bar(aes(y = percent * -1), filter(demographic_data, gender == 'F'), 
             stat = 'identity', width = 0.6, 
             position = position_dodge(width = 0.5)) +
    geom_text(aes(label = paste(percent, "%")), hjust = -0.1, size = 3,
              filter(demographic_data, gender == 'M')) +
    geom_text(aes(label = paste(percent, "%"), y = percent * -1), hjust = 1.1,
              size = 3, filter(demographic_data, gender == 'F')) +
    coord_flip() +
    xlab('Age group') +
    ylab('Percent in each age group') +
    scale_fill_brewer(name = 'Gender', labels = c('Female', 'Male'), 
                      palette = 'Set1') +
    scale_y_continuous(breaks = seq(y_max * -1, y_max, 10),
                       labels = abs(seq(y_max * -1, y_max, 10)),
                       limits = c((y_max * -1) - 1, y_max + 1)) +
    theme(
      panel.grid.major = element_blank()
      ), 
    silent = TRUE
  )
  
  return(g)
}


