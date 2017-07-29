FROM debian:stretch-slim
MAINTAINER "Ian Carroll" icarroll@sesync.org

# Installation steps

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

## base packages
RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
      build-essential \
      apt-utils \
 && apt-get install -yq --no-install-recommends \
      curl \
      gnupg2 \
      nginx \
      openssh-client \
      ca-certificates
      
## open science libraries and utilities
RUN apt-get install -yq --no-install-recommends \
      libgdal-dev \
      libudunits2-dev \
      libnlopt-dev \
      git

## s6-overlay process supervisor
RUN curl -sL https://github.com/just-containers/s6-overlay/releases/download/v1.11.0.1/s6-overlay-amd64.tar.gz | tar xz

## add NodeSource repository and nodejs (JupyterHub requirement)
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
      nodejs

## R and RStudio
RUN apt-get install -yq --no-install-recommends \
      r-base \
      r-base-dev \
      libapparmor1 \
      libcurl4-openssl-dev \
      libxml2-dev \
      gdebi-core
#FIXME outdated library is hardcoded in rstudio server: https://support.rstudio.com/hc/en-us/community/posts/115005872767-R-Studio-Server-install-fails-hard-coded-libssl1-0-0-dependency-out-of-date-
RUN curl -sL http://ftp.debian.org/debian/pool/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u6_amd64.deb -o /tmp/libssl1.0.0.deb \
 && dpkg -i /tmp/libssl1.0.0.deb \
 && rm /tmp/libssl1.0.0.deb
RUN curl -sL http://www.rstudio.org/download/latest/stable/server/ubuntu64/rstudio-server-latest-amd64.deb -o /tmp/rstudio.deb \
 && gdebi --non-interactive /tmp/rstudio.deb \
 && rm /tmp/rstudio.deb

## Python and JupyterHub
RUN apt-get install -yq --no-install-recommends \
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
      jupyter \
      jupyterhub \
      jupyter-console \
      ipywidgets \
 && npm install -g \
      configurable-http-proxy

#FIXME needing this (empty?) directory seems to be a bug with debian-slim
#https://github.com/resin-io-library/base-images/commit/a56e1e5b4ca29a941cb23b0325784fd1a7732bca
RUN mkdir -p /usr/share/man/man1 \
 && mkdir -p /usr/share/man/man7

## PostgreSQL
RUN apt-get install -yq --no-install-recommends \
      postgresql \
      postgresql-contrib \
 && usermod -a -G shadow postgres

## pgStudio (java requiremnt; software is in /usr/share/pgstudio)
RUN apt-get install -yq --no-install-recommends \
      default-jdk
        
## Packages and Modules
#FIXME makevar for root packages
## R packages
RUN echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl')" >> /usr/lib/R/etc/Rprofile.site \
 && Rscript -e 'install.packages(c( \
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
      requests \
      census

# Data & Configuration steps
## for configuration of s6-overlay services (see root/etc/services.d)

ADD root /

## Initialize postgresql and "student" role
RUN service postgresql start \
 && su - postgres -c "psql -qc 'REVOKE ALL ON schema public FROM public'" \
 && su - postgres -c "createdb portal" \
 && su - postgres -c "createuser --no-login student" \
 && su - postgres -c "psql portal -qc 'ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO student'" \
 && su - postgres -c "psql portal -q < /var/backups/postgresql/portal_dump.sql" \
 && service postgresql stop \
 && sed -e "s|\(127.0.0.1/32\s*\)md5|\1pam pamservice=postgresql96|" -i /etc/postgresql/9.6/main/pg_hba.conf

## remove JupyterHub username -> lowercase "normalization"
RUN sed -e "/username = username.lower()/d" -i /usr/local/lib/python3.5/dist-packages/jupyterhub/auth.py

## fix PostgreSQL on linux host
## see https://github.com/docker/docker/issues/783#issuecomment-56013588
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
