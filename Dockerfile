FROM rocker/rstudio:latest
MAINTAINER "Ian Carroll" icarroll@sesync.org

## base packages
ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
RUN apt-get update
RUN apt-get install -yq --no-install-recommends \
    build-essential \
    apt-utils \
    curl \
    gnupg2 \
    nginx

## add NodeSource repository and nodejs
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get update
RUN apt-get install -yq --no-install-recommends \
    nodejs

## OSGeo
RUN apt-get install -yq --no-install-recommends \
    libgdal-dev

## RStudio
RUN Rscript -e 'install.packages(c( \
    "rgdal", \
    "shiny"  \
    ), dependencies = TRUE)'

## JupyterHub
RUN apt-get install -yq --no-install-recommends \
    python3-all \
    python3-pip
RUN pip3 install --upgrade pip
RUN pip3 install \
    setuptools \
    wheel
RUN pip3 install \
    pandas \
    sqlalchemy \
    tornado \
    jinja2 \
    traitlets \
    requests \
    notebook \
    jupyterhub

RUN npm install -g \
    configurable-http-proxy

ADD root /

VOLUME /handouts

EXPOSE 80

ENTRYPOINT ["/init"]

## ideas
# simple web server that links to adduser, rstudio, jupyter, etc ..., explains volume mounting
# use gitlab pages as web server and git 'origin'
# ssh-keygen: could put a private ssh key in the docker file, for GitHub ... but maybe not needed without the handouts repo.
# what does user namespaces on docker allow?
# curl the handouts repo

## fixmes
# R packages cairo and rgdal not installing?, missing cairo.h and proj_api.h
