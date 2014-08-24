
# Load libraries, source files and config files --------------------------------

library(shiny)
library(yaml)

source('rScripts/utils.R')
config <- yaml.load_file('config.yml')


# Define server-side logic of the Shiny app ------------------------------------

shinyServer(function(input, output, session) {
  
  
  source('data/downloaded_data.R', local = TRUE)
  
  # Create new reactive variable
  selectedCountry <- 'Entire Region'
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
  
  output$summaryInformationTitle <- renderText({
    paste('Basic refugee information for', selectedCountry)
  })
  
  output$peopleOfConcern <- renderText({
    paste('Total people of concern:',
          unhcr_data %>% 
            filter(name == selectedCountry) %>% 
            select(people_of_concern))
  })
  
  output$registeredRefugees <- renderText({
    paste('Registered Syrian refugees:',
          unhcr_data %>% 
            filter(name == selectedCountry) %>% 
            select(registered_syrian_refugees))
  })
  
  output$peopleAwaitingRegistration <- renderText({
    paste('Persons awaiting registration:',
          unhcr_data %>% 
            filter(name == selectedCountry) %>% 
            select(persons_awaiting_registration))
  })
  
  output$pyramidPlotLabel <- renderText({
    paste('Demographic refugee breakdown for', selectedCountry)
    
  })
  
  
  output$pyramidPlot <- renderPlot({
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
      # Clear existing circles before drawing
      map$clearShapes()
      
      circle_data <- unhcr_data %>% filter(name != 'Entire Region')
      map$addCircle(circle_data$latitude, circle_data$longitude, 
                    circle_data$radius, circle_data$name, list(weight=1.2, 
                                                  fill=TRUE, 
                                                  color='#4A9')
      )
    })
  })
  
  # Observer for handling click event on empty map/on areas with no circles
  observe({
    if (is.null(input$map_click))
      return()
    # Set the reactive variable to 'Entire region' so that reactive
    # functions downstream can re-calculate
    selectedCountry <<- 'Entire Region'
  })
  
  # Observer for handling click event on circles
  observe({
    event <- input$map_shape_click
    if(is.null(event))
      return()
    
    map$clearPopups()
    
    isolate({
      country <- filter(unhcr_data, name == event$id)
      # Set the reactive variable to the selected country so that reactive
      # functions downstream can re-calculate
      selectedCountry <<- country$name
      content <- as.character(tagList(
        tags$strong(country$name),
        tags$br(),
        "Check out the country-specific data below"
        ))
      map$showPopup(event$lat, event$lng, content, event$id)
    })
  })
  
})