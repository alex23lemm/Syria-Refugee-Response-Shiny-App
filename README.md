# Syria Refugee Dashboard - A Shiny App

Re-engineered version of the [Syria Regional Refugee Response Portal](http://data.unhcr.org/syrianrefugees/regional.php) originally provided by the UN Refugee Agency (UNHCR) based on [R](http://www.r-project.org/), [Shiny](http://http://shiny.rstudio.com/), and [Leaflet](http://leafletjs.com/).

The version of the app residing in the master branch was deployed to [ShinyApps.io](https://www.shinyapps.io/) and can be accessed [here](http://bit.ly/1omK3gb).

You may also want to visit the project-specific web page (gh-pages branch) [here](http://alex23lemm.github.io/Syria-Refugee-Response-Shiny-App/).


## Installation

### Installation on local machine

If you want to run the app locally on your machine, make sure to install at least `R version 3.1.1` and the following libraries:

* devtools
* leaflet
* shiny
* yaml
* jsonlite
* curl
* plyr
* dplyr
* tidyr
* ggplot2
* RColorBrewer
* markdown

It is important to install `leaflet` and `shiny` via `devtools` in order to use minor versions:

    devtools::install_github("jcheng5/leaflet-shiny")
    devtools::install_github('rstudio/shiny@v0.10.2.2')


After installing the prerequisites, download or git clone the entire content of the repo and store it in a folder of your choice. Assuming that the new folder will be your R working directory, use the `runApp` command to launch the app. 

    library(shiny)
    runApp('.')
    
If you do not want to download the entire repo content yourself, you can use the `runGitHub` command as an alternative. 

    library(shiny)
    runGitHub('Syria-Refugee-Response-Shiny-App', 'alex23lemm')
    
### Installation on Ubuntu server

If you would like to install the application on an Ubuntu server instance (e.g. a T2.micro Amazon EC2 instance) you can excute the bash script `setup.sh` that is part of this repo. The script will install the following:

* Create and enable swap file: necessary when running on a T2.mirco EC2 instance. You won't be able to install certain R packages (e.g. `dplyr`, `tidyr`) without the additional allocated memory from the swap file
* The latest R distribution for Ubuntu Trusty
* Git
* Shiny server
* The devtools package including the necessary Linux packages
* R GitHub packages necessary to run the Shiny app
* R CRAN packages necessary to run the Shiny app
* The Shiny app (via git clone)

After running the script the Syria Refugee Dashboard app will be available at `http://[server IP address]:3838/Syria-Refugee-Response-Shiny-App`





