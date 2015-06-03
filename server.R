
# Load libraries, source files and config files --------------------------------

library(shiny)
library(yaml)
library(leaflet)

source('rScripts/utils.R')
config <- yaml.load_file('config.yml')


# Define server-side logic of the Shiny app ------------------------------------

shinyServer(function(input, output, session) {
  
  # Source data sets that were deployed with the app. This includes:
  # unhcr_data:       Downloaded and processed population data for all countries
  #                   monitored in the Syria instance of the UNHCR
  # demographic_data: Processed demographic data for all countries monitored in 
  #                   the Syria instance and derived from unhcr_data
  # date_downloaded:  Date the UNHCR data was originally downloaded and 
  #                   processed
  source('data/downloaded_data.R', local = TRUE)
  
  # Create new reactive variable
  selectedCountry <- 'Entire Region'
  makeReactiveBinding('selectedCountry')
  
  
  # Turn sourced variables into reactive variables. This is an important step in
  # order to use the leaflet map as an input device for end users 
  makeReactiveBinding('unhcr_data')
  makeReactiveBinding('demographic_data')
  makeReactiveBinding('date_downloaded')
  
  # In every session the dumped data is shown intitally. When the user clicks 
  # on the action button new data will be downloaded from the UN servers via 
  # the funciton in utils.R
  observe({
    if(input$downloadButton == 0)
      return()
    
    # Update reactive variables with downloaded data
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
    pyramidPlot <- try(create_pyramid_plot(demographic_data, selectedCountry))
    shiny::validate(
     need(pyramidPlot, "No demographic data available for this region")
    )
    pyramidPlot
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
      
      # Since unhcr_data is a reactive variable the circles on the map will be
      # re-drawn every time new data was downloaded
      circle_data <- unhcr_data %>% filter(name != 'Entire Region')
      
      # The data used as the first four arguments will later be retrieved
      # by input$map_shape_click when the user clicks on one of the circles
      map$addCircle(circle_data$latitude, circle_data$longitude, 
                    circle_data$radius, circle_data$name, list(weight=1.2, 
                                                  fill=TRUE, 
                                                  color='#4A9')
      )
    })
  })
  
  # Observer for handling click events on empty map/on areas with no circles
  observe({
    if (is.null(input$map_click))
      return()
    
    # Set the reactive variable to 'Entire region' so that reactive
    # functions downstream can re-calculate
    selectedCountry <<- 'Entire Region'
  })
  
  # Observer for handling click event on circles
  observe({
    # input$map_shape_click will return the data (of a single circle) which was 
    # used to add the respetive circle to the map via map$addCircle above 
    event <- input$map_shape_click
    if(is.null(event))
      return()
    
    map$clearPopups()
    
    isolate({
      # event$id corresponds to the country name which was added as the fourth
      # argument via map$addCircle() above
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