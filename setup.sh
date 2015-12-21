#!/bin/bash 

# Ubuntu setup and package installation
sudo apt-get upgrade
sudo apt-get -y install git

# Create and enable swap file
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile


# R installation
sudo sh -c "echo 'deb https://cran.rstudio.com/bin/linux/ubuntu trusty/' >> /etc/apt/sources.list"
sudo apt-get update
sudo apt-get --yes --force-yes install r-base r-base-dev

# Shiny server installation
sudo su - -c "R -e \"install.packages(c('shiny', 'rmarkdown'), repos='https://cran.rstudio.com/')\""
sudo apt-get -y install gdebi-core
wget https://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-1.4.1.759-amd64.deb
sudo gdebi shiny-server-1.4.1.759-amd64.deb

# Install devtools
sudo apt-get -y install libcurl4-gnutls-dev libxml2-dev libssl-dev
sudo su - -c "R -e \"install.packages('devtools', repos='http://cran.rstudio.com/')\""

# Install GitHub R packages
sudo su - -c "R -e \"devtools::install_github('jcheng5/leaflet-shiny')\""
sudo su - -c "R -e \"devtools::install_github('rstudio/shiny@v0.10.2.2')\""

# Install CRAN R packages
sudo su - -c "R -e \"install.packages(c('yaml','jsonlite','plyr','dplyr','tidyr','ggplot2','RColorBrewer','markdown'), repos='https://cran.rstudio.com/')\""

# Install shiny app
sudo git clone https://github.com/alex23lemm/Syria-Refugee-Response-Shiny-App.git
sudo mv Syria-Refugee-Response-Shiny-App /srv/shiny-server









