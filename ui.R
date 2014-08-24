library(shiny)
library(leaflet)

shinyUI(navbarPage('Syria Regional Refugee Response',
                               
  tabPanel('Regional Overview',
           
    includeCSS('style.css'), 
           
    leafletMap(
      "map", width="100%", height="400px",
      initialTileLayer = "http://a.tiles.mapbox.com/v3/unhcr.map-8bkai3wa/{z}/{x}/{y}.png",    
      initialTileLayerAttribution = HTML('Maps by <a href="http://www.mapbox.com/">Mapbox</a>'),
      options=list(
        center = c(34.398, 40.649),
        zoom = 5
      )
     ),
    
    absolutePanel(id = "controls", class = "modal", fixed = FALSE, draggable = FALSE,
                  top = 60, left = "auto", right = 20, bottom = "auto",
                  width = 280, height = "auto",
                  
      h3("Instructions"),
      p('This Shiny app provides basic visualizations and summary stats about 
        the current Syrian refugee crisis.'),
      p('Clicking on one of the circles will show you country-specific data below. The bigger
        the circle radius the more refugees are residing in the respecitve country. If you
        would like to get back to the general view of the entire region, just click on a 
        non-circle area.'), 
      p('This app comes with a pre-installed data set. Clicking the button on the left will
        download new data from the United Nations servers.')
    ),
    
    
    
    
     fluidRow(
       column(8, offset = 3,
         h2('Syrian Refugees in the Middle East'),
         hr()
         
         
       )
     ),
    
    fluidRow(
      column(3,
             p(tags$i(class = 'icon-time'), 'Data last updated on:', textOutput('date')),
             br(),
             actionButton('downloadButton', 'Refresh data', 
                          icon("cloud-download")),
             helpText('Info: Clicking the button will download new data 
                      from the United Nations servers to the Shiny server for the active
                      user session.')
             
      ),
      
      column(4,
        h4(textOutput('summaryInformationTitle')),
        br(),
        textOutput('peopleOfConcern'),
        textOutput('registeredRefugees'),
        textOutput('peopleAwaitingRegistration')
             
      ),
      
      column(5,
        h4(textOutput('pyramidPlotLabel')),
        plotOutput('pyramidPlot',  width='100%', height='250px')
      )
    )
    

    
  ),
  
  tabPanel('About'
    
  )
     
  ))