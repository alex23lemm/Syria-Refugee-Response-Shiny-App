
# Load libraries, source files and config files --------------------------------

library(shiny)
library(yaml)

source('utils.R')
source('downloaded_data.R')
config <- yaml.load_file('config.yml')


shinyServer(function(input, output, session) {
  
  source('downloaded_data.R', local = TRUE)
  
  makeReactiveBinding('unhcr_data')
  makeReactiveBinding('demographic_data')
  makeReactiveBinding('date_downloaded')
  
  source('downloaded_data.R')
  
  observe({
    if(input$downloadButton == 0)
      return()
    
    unhcr_data <<- get_UNHCR_population_data(config$country_url)
    demographic_data <<- tidy_demographic_data(unhcr_data)
    date_downloaded <<- date()
  })
  
  
  output$date <- renderText({
    
    date_downloaded
  })
  
  
  output$pyramid_plot <- renderPlot({
    create_pyramid_plot(demographic_data, input$country_name)
  })
  
  map <- createLeafletMap(session, 'map')
  

})