FROM sesync/lab-debian
MAINTAINER "Ian Carroll" icarroll@sesync.org

# # System Configuration
#
# /etc/apt/sources.list.d/* = additional sources for r-base and r-cran-* packages

ADD root /

# R and RStudio

ADD cran.gpg.key .
RUN gpg --import cran.gpg.key \
 && gpg --export --armor E19F5F87128899B192B1A2C2AD5F960A256A04AF | apt-key add - \
 && rm cran.gpg.key \
 && apt-get update \
 && apt-get install -yq --no-install-recommends \
      libcurl4-openssl-dev \
      libxml2-dev \
      libssl-dev \
 && apt-get install -yq --no-install-recommends \
      r-base \
      r-base-dev \
      libapparmor1 \
      gdebi-core
### FIXME outdated library is hardcoded in rstudio server
### https://support.rstudio.com/hc/en-us/community/posts/115005872767-R-Studio-Server-install-fails-hard-coded-libssl1-0-0-dependency-out-of-date-
RUN curl -sL http://ftp.debian.org/debian/pool/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u8_amd64.deb -o libssl1.0.0.deb \
 && dpkg -i libssl1.0.0.deb \
 && rm libssl1.0.0.deb
RUN curl -sL https://download2.rstudio.org/server/debian9/x86_64/rstudio-server-1.2.1335-amd64.deb -o rstudio.deb \
  && gdebi --non-interactive rstudio.deb \
  && rm rstudio.deb

## Packages for Lessons

# RUN echo "local({ \
#       r <- getOption('repos'); \
#       r['download.file.method'] <- 'libcurl'; \
#       options(repos = r); \
#       options(datatable.na.strings = '')})" >> /usr/lib/R/etc/Rprofile.site \
#  && Rscript -e "Sys.setenv(MAKEFLAGS = '-j8'); \
#       install.packages(type = 'source', pkgs = c( \
#       'base64enc', \
#       'bitops', \
#       'BMS', \
#       'caTools', \
#       'caret', \
#       'codetools', \
#       'colorRamps', \
#       'classInt', \
#       'data.table', \
#       'dbplyr', \
#       'evaluate', \
#       'e1071', \
#       'forecast', \
#       'foreign', \
#       'formatR', \
#       'gdata', \
#       'ggplot2', \
#       'gridExtra', \
#       'gstat', \
#       'gtools', \
#       'highr', \
#       'knitr', \
#       'leaflet', \
#       'lubridate', \
#       'lme4', \
#       'magick', \
#       'mapview', \
#       'maptools', \
#       'markdown', \
#       'modules', \
#       'network', \
#       'nnet', \
#       'plyr', \
#       'plotrix', \
#       'psych', \
#       'randomForest', \
#       'raster', \
#       'rasterVis', \
#       'readr', \
#       'readxl', \
#       'rgdal', \
#       'rgeos', \
#       'ROCR', \
#       'rmarkdown', \
#       'RPostgreSQL', \
#       'rpart', \
#       'rprojroot', \
#       'rstanarm', \
#       'servr', \
#       'sf', \
#       'shiny', \
#       'SnowballC', \
#       'sp', \
#       'spdep', \
#       'sphet', \
#       'stargazer', \
#       'stars', \
#       'stringr', \
#       'tidyr', \
#       'tidytext', \
#       'tm', \
#       'topicmodels', \
#       'TOC', \
#       'wordcloud', \
#       'xts', \
#       'zoo'))"

# Docker Configuration

VOLUME /home
VOLUME /nfs
CMD ["/usr/lib/rstudio-server/bin/rserver","--server-daemonize=0"]