
# Install R
sudo apt-get install r-base r-base-core r-recommended

# Install Rstudio Server:  https://www.rstudio.com/products/rstudio/download-server/
sudo apt-get install gdebi-core
sudo apt-get -f install

# Install dependencies needed for many R packages
sudo apt-get -y install libcurl4-gnutls-dev libxml2-dev libssl-dev libsasl2-dev

# Install R shiny and Shiny Server: https://www.rstudio.com/products/shiny/download-server/ 
sudo su - \
-c "R -e \"install.packages('shiny', repos='https://cran.rstudio.com/')\""
wget https://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-1.5.5.872-amd64.deb
sudo gdebi shiny-server-1.5.5.872-amd64.deb

# Configure Shiny Server: http://docs.rstudio.com/shiny-server/