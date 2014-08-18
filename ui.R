library(shiny)
library(leaflet)

shinyUI(fluidPage(
    
  leafletMap(
    "map", "100%", 400,
    #initialTileLayer ="http://a.tiles.mapbox.com/v3/mapbox.control-room/{z}/{x}/{y}.png",
    initialTileLayer = "http://a.tiles.mapbox.com/v3/unhcr.map-8bkai3wa/{z}/{x}/{y}.png",    
    initialTileLayerAttribution = HTML('Maps by <a href="http://www.mapbox.com/">Mapbox</a>'),
    options=list(
      center = c(34.398, 40.649),
      zoom = 5
    ))
  
  ))