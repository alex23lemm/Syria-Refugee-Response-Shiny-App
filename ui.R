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
    
     fluidRow(
       column(8, offset = 3,
         h2('Syrian Refugees in the Middle East'),
         p(tags$i(class = 'icon-time'), 'Data last updated on:', textOutput('date')),
         actionButton('downloadButton', 'Refresh data')
         
       )
     ),
    
    fluidRow(
      column(4,
        selectInput('country_name', label = 'test', choices = list('Turkey', 'Lebanon',
                                                                   'Iraq', 'Jordan', 'Egypt'), 
                    selected = 'Turkey')     
             
      ),
      column(8,
        plotOutput('pyramid_plot', width='70%', height='280px')
      )
    )
    

    
  ),
  
  tabPanel('About'
    
  )
    

  
  ))