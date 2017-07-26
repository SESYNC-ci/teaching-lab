FROM debian:stretch-slim
MAINTAINER "Ian Carroll" icarroll@sesync.org

#FIXME  && echo "R_LIBS_USER='~/R/library'" >> /usr/local/lib/R/etc/Renviron

# Installation steps

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

## base packages
RUN apt-get update -yq --no-install-recommends \
 && apt-get install \
      build-essential \
      apt-utils \
 && apt-get install \
      curl \
      gnupg2 \
      nginx \
      openssh-client \
      gdebi-core \

WORKDIR /tmp

## s6-overlay process supervisor
RUN curl -sLo https://github.com/just-containers/s6-overlay/releases/download/v1.11.0.1/s6-overlay-amd64.tar.gz \
 && tar xzf s6-overlay-amd64.tar.gz -C / \

## add NodeSource repository and nodejs (JupyterHub requirement)
RUN curl -sLo https://deb.nodesource.com/setup_6.x \
 && bash setup_6.x \
 && apt-get update -yq --no-install-recommends \
 && apt-get install \
      nodejs

## open science libraries and utilities
RUN apt-get install \
      libgdal-dev \
      libudunits2-dev \
      libnlopt-dev \
      git

## R and RStudio
RUN apt-get install \
      r-base \
      r-base-dev \
RUN curl -sLo http://www.rstudio.org/download/latest/stable/server/ubuntu64/rstudio-server-latest-amd64.deb \
 && gdebi rstudio-server-latest-amd64.deb

## Python and JupyterHub
RUN apt-get install \
      python3 \
      python3-dev \
      python3-pip \
 && pip3 install --upgrade pip \
 && pip3 install \
      setuptools \
      wheel \
 && pip3 install \
      tornado \
      jinja2 \
      traitlets \
      requests \
      jupyter \
      jupyterhub \
      jupyter-console \
      ipywidgets \
 && npm install -g \
      configurable-http-proxy

## pgStudio (java requiremnt; software is in /usr/share/pgstudio)
RUN apt-get install \
      default-jdk
        
## PostgreSQL
RUN apt-get install \
      postgresql \
      postgresql-contrib \
 && usermod -a -G shadow postgres
      
## Packages and Modules
#FIXME makevar for root packages
## R packages
RUN Rscript -e 'install.packages(c( \
      "evaluate", \
      "formatR", \
      "highr", \
      "markdown", \
      "yaml", \
      "caTools", \
      "bitops", \
      "knitr", \
      "base64enc", \
      "rprojroot", \
      "rmarkdown", \
      "codetools", \
      "gridExtra", \
      "RPostgreSQL", \
      "dbplyr", \
      "tidyr", \
      "ggplot2", \
      "rgdal", \
      "sf", \
      "raster", \
      "stargazer", \
      "shiny", \
      "lme4", \
      "tm", \
      "SnowballC", \
      "stringr", \
      "network"))' \
 && Rscript -e 'install.packages("rstan", \
      repos = "https://cloud.r-project.org/", \
      configure.args = "CXXFLAGS=-O3 -mtune=native -march=native -Wno-unused-variable -Wno-unused-function -flto -ffat-lto-objects  -Wno-unused-local-typedefs -Wno-ignored-attributes -Wno-deprecated-declarations", \
      dependencies = TRUE)'

## Python modules
RUN pip3 install \
      numpy \
      pandas \
      pygresql \
      sqlalchemy \
      beautifulsoup4 \
      census

# Data & Configuration steps

## include configuration for s6-overlay services (see root/etc/services.d)
ADD root /

## Initialize postgresql and "student" role
RUN service postgresql start \
 && su - postgres -c "createuser --no-login student" \
 && su - postgres -c "createdb portal -O student" \
 && su - postgres -c "psql -q portal < /var/backups/postgresql/portal_dump.sql" \
 && su - postgres -c "psql -qc 'REVOKE ALL ON schema public FROM public'" \
 && service postgresql stop \
 && sed -e "s|\(127.0.0.1/32\s*\)md5|\1pam pamservice=postgresql96|" -i /etc/postgresql/9.6/main/pg_hba.conf

## remove JupyterHub username -> lowercase "normalization"
RUN sed -e "/username = username.lower()/d" -i /usr/local/lib/python3.5/dist-packages/jupyterhub/auth.py

## fix PostgreSQL on linux host
## Mike pointed to
## https://github.com/docker/docker/issues/783#issuecomment-56013588
RUN mkdir /etc/ssl/private-copy \
 && mv /etc/ssl/private/* /etc/ssl/private-copy/ \
 && rm -r /etc/ssl/private \
 && mv /etc/ssl/private-copy /etc/ssl/private \
 && chmod -R 0700 /etc/ssl/private \
 && chown -R postgres /etc/ssl/private

## expose user data to host
VOLUME /home

ENV USER=""

EXPOSE 80

ENTRYPOINT ["/init"]
