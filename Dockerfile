FROM rocker/rstudio:latest
MAINTAINER "Ian Carroll" icarroll@sesync.org

# Mod rocker-org configuration
RUN rm -rf /etc/cont-init.d \
 && echo "R_LIBS_USER='~/R/library'" >> /usr/local/lib/R/etc/Renviron

# Installation steps

## base packages
ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
      build-essential \
      apt-utils
RUN apt-get install -yq --no-install-recommends \
      curl \
      gnupg2 \
      nginx \
      openssh-client

## add NodeSource repository and nodejs (JupyterHub requirement)
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
      nodejs

## open science libraries
RUN apt-get install -yq --no-install-recommends \
      libgdal-dev \
      libudunits2-dev

## JupyterHub
RUN apt-get install -yq --no-install-recommends \
      python3-all \
      python3-dev \
      python3-pip
RUN pip3 install --upgrade pip
RUN pip3 install \
      setuptools \
      wheel
RUN pip3 install \
      tornado \
      jinja2 \
      traitlets \
      requests \
      jupyter \
      jupyterhub \
      jupyter-console \
      ipywidgets
      
RUN npm install -g \
      configurable-http-proxy

## pgStudio (java requiremnt; software is in /usr/share/pgstudio)
RUN apt-get install -yq --no-install-recommends \
      default-jdk
        
## PostgreSQL
RUN apt-get install -yq --no-install-recommends \
      postgresql \
      postgresql-contrib && \
      usermod -a -G shadow postgres

## git LFS
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash \
 && apt-get install -yq --no-install-recommends \
      git-lfs
      
## Packages and Modules

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
      "shiny"))'

## Python modules
RUN pip3 install \
      numpy \
      pandas \
      pygresql \
      sqlalchemy

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

## add an empty "network file storage" for user data
VOLUME /share

ENV USER=""

EXPOSE 80

ENTRYPOINT ["/init"]

## ideas
# use gitlab pages as web server and git 'origin'?
# ssh-keygen: could put a private ssh key in the docker file, for GitHub ... but maybe not needed without the handouts repo.
# what does user namespaces on docker allow?
# curl/clone the handouts repo?
# if everyone "imports" the handouts on GitHub, then clones locally with data - they can all push to share solutions, and handouts are within /home/username/reponame
# would be tidy to remove the /home/rstudio/kitematic ...
