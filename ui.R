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
         hr()
         
         
       )
     ),
    
    fluidRow(
      column(3,
             p(tags$i(class = 'icon-time'), 'Data last updated on:', textOutput('date')),
             actionButton('downloadButton', 'Refresh data')
             
      ),
      
      column(4,
        'Basic refugee information for '
             
      ),
      
      column(5,
        textOutput('pyramidPlotLabel'),
        plotOutput('pyramid_plot',  width='100%', height='250px')
      )
    )
    

    
  ),
  
  tabPanel('About'
    
  )
    

  
  ))