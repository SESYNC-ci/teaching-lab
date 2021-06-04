FROM sesync/lab-debian
MAINTAINER "Ian Carroll" icarroll@sesync.org

# # System Configuration
#
# /etc/apt/sources.list.d/* = additional sources for r-base and r-cran-* packages

ADD root/etc/apt /etc/apt

# R and RStudio

ADD cran.gpg.key .
RUN gpg --import cran.gpg.key \
 && gpg --export --armor E19F5F87128899B192B1A2C2AD5F960A256A04AF | apt-key add - \
 && rm cran.gpg.key \
 && apt-get update \
 && apt-get install -yq --no-install-recommends \
     # libcurl4-openssl-dev \
      libxml2-dev \
      libssl-dev \
      librdf0-dev \
      r-base \
      r-base-dev \
      libapparmor1 \
      gdebi-core
### FIXME outdated library is hardcoded in rstudio server
### https://support.rstudio.com/hc/en-us/community/posts/115005872767-R-Studio-Server-install-fails-hard-coded-libssl1-0-0-dependency-out-of-date-
#RUN curl -sL http://ftp.debian.org/debian/pool/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u8_amd64.deb -o libssl1.0.0.deb \
# && dpkg -i libssl1.0.0.deb \
# && rm libssl1.0.0.deb
RUN curl -sL https://download2.rstudio.org/server/bionic/amd64/rstudio-server-1.3.959-amd64.deb -o rstudio.deb \
  && gdebi --non-interactive rstudio.deb \
  && rm rstudio.deb

## Packages for Lessons

RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
      libv8-dev
RUN echo "local({ \
      options(download.file.method = 'libcurl'); \
      options(datatable.na.strings = '')})" >> /usr/lib/R/etc/Rprofile.site \
 && Rscript -e "Sys.setenv(MAKEFLAGS = '-j8'); \
      install.packages(type = 'source', lib = '/usr/lib/R/site-library', pkgs = c( \
      'base64enc', \
      'bitops', \
      'BMS', \
      'caTools', \
      'caret', \
      'censusapi', \
      'codetools', \
      'colorRamps', \
      'classInt', \
      'cubelyr', \
      'datapack', \
      'dataone', \
      'data.table', \
      'DBI', \
      'dbplyr', \
      'EML', \
      'emld', \
      'evaluate', \
      'e1071', \
      'jsonlite', \
      'forecast', \
      'foreign', \
      'formatR', \
      'gdata', \
      'ggplot2', \
      'ggwordcloud', \
      'gridExtra', \
      'gstat', \
      'gtools', \
      'here', \
      'highr', \
      'httr', \
      'jsonlite', \
      'knitr', \
      'leaflet', \
      'lubridate', \
      'lme4', \
      'magick', \
      #'mapview', \
      'maptools', \
      'markdown', \
      'modules', \
      'network', \
      'nnet', \
      'plyr', \
      'plotrix', \
      'psych', \
      'randomForest', \
      'raster', \
      'rasterVis', \
      'readr', \
      'readxl', \
      'remotes', \
      'reticulate', \
      'rgdal', \
      'rgeos', \
      'ROCR', \
      'rmarkdown', \
      'RPostgreSQL', \
      'rpart', \
      'rprojroot', \
      'RSQLite', \
      'rstanarm', \
      'rvest', \
      'servr', \
      'sf', \
      'shiny', \
      'SnowballC', \
      'sp', \
      'spatialreg', \
      'spdep', \
      'sphet', \
      'stargazer', \
      #'stars', \
      'stringr', \
      'tidycensus', \
      'tidyr', \
      'tidytext', \
      'tidyverse', \
      'tm', \
      'topicmodels', \
      'TOC', \
      'uuid', \
      'wordcloud', \
      'xts', \
      'zoo'))"
RUN Rscript -e "library(remotes); \
      install_github('ropenscilabs/dataspice', lib = '/usr/lib/R/site-library'); \
      install_github('r-spatial/mapview@09b14f9', lib = '/usr/lib/R/site-library'); \
      install_github('r-spatial/stars', lib = '/usr/lib/R/site-library')"

# Docker Configuration

VOLUME /home
VOLUME /nfs

CMD ["/usr/lib/rstudio-server/bin/rserver","--server-daemonize=0"]
