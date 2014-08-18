library(shiny)



shinyServer(function(input, output, session) {
  
  map <- createLeafletMap(session, 'map')
  
  
})