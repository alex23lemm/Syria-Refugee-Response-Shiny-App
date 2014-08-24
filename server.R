
# Load libraries, source files and config files --------------------------------

library(shiny)
library(yaml)

source('utils.R')
config <- yaml.load_file('config.yml')


shinyServer(function(input, output, session) {
  
  
  source('downloaded_data.R', local = TRUE)
  
  # Create new reactive variable
  selectedCountry <- 'Turkey'
  makeReactiveBinding('selectedCountry')
  
  
  # Turn sourced variables into reactive variables
  makeReactiveBinding('unhcr_data')
  makeReactiveBinding('demographic_data')
  makeReactiveBinding('date_downloaded')
  
  # In every session the dumped data is shown intitally. When the user clicks 
  # on the action button new data will be downloaded from the UN servers via 
  # the funciton in utils.R
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
  
  output$pyramidPlotLabel <- renderText({
    paste('Demographic refugee breakdown for', selectedCountry)
    
  })
  
  
  output$pyramid_plot <- renderPlot({
    create_pyramid_plot(demographic_data, selectedCountry)
  })
  
  
  # Create the map; this is not the "real" map, but rather a proxy
  # object that controls the leaflet map on the web page
  map <- createLeafletMap(session, 'map')
  
  # session$onFlushed is necessary to work around a bug in the Shiny/Leaflet
  # integration; without it, the addCircle commands arrive in the browser
  # before the map is created
  session$onFlushed(once=TRUE, function() {
    observe({
      map$addCircle(unhcr_data$latitude, unhcr_data$longitude, 
                    100000, unhcr_data$name, list(weight=1.2, 
                                                  fill=TRUE, 
                                                  color='#4A9')
      )
    })
  })
  
  
  observe({
    event <- input$map_shape_click
    if(is.null(event))
      return()
    
    map$clearPopups()
    
    isolate({
      country <- filter(unhcr_data, name == event$id)
      selectedCountry <<- country$name
      content <- as.character(tagList(
        tags$strong(country$name)
        ))
      map$showPopup(event$lat, event$lng, content, event$id)
    })
  })
  
  
  
  
  
  

})