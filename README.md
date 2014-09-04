# Syria Refugee Dashboard - A Shiny App

Re-engineered version of the [Syria Regional Refugee Response Portal](http://data.unhcr.org/syrianrefugees/regional.php) originally provided by the UN Refugee Agency (UNHCR) based on [R](http://www.r-project.org/), [Shiny](http://http://shiny.rstudio.com/), and [Leaflet](http://leafletjs.com/).

The version of the app residing in the master branch was deployed to [ShinyApps.io](https://www.shinyapps.io/) and can be accessed [here](http://bit.ly/1omK3gb).


## Installation

If you want to run the app locally on your machine, make sure to install at least `R version 3.1.1` and the following libraries:

* devtools
* shiny
* yaml
* jsonlite
* httr
* plyr
* dplyr
* tidyr
* leaflet
* ggplot2
* RColorBrewer
* markdown

`leaflet` and `tidyr` needs to be installed via `devtools`:

    devtools::install_github("jcheng5/leaflet-shiny")
    devtools::install_github("hadley/tidyr")

After installing the prerequisites, download the entire content of the repo and store it in a folder of your choice. Assuming that the new folder will be your R working directory, use the `runApp` command to launch the app. 

    library(shiny)
    runApp('.')
    
If you do not want to download the entire repo content yourself, you can use the `runGitHub` command as an alternative. 

    library(shiny)
    runGitHub('Syria-Refugee-Response-Shiny-App', 'alex23lemm')
