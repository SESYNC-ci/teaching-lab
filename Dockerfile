FROM debian:stretch-slim
MAINTAINER "Ian Carroll" icarroll@sesync.org

## FIXME update-alternatives to blame
## https://github.com/debuerreotype/debuerreotype/issues/10
RUN mkdir -p \
      /usr/share/man/man1/ \
      /usr/share/man/man7/

# System/Debian Packages

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
      build-essential \
      apt-utils \
 && apt-get install -yq --no-install-recommends \
      curl \
      gnupg2 \
      nginx \
      openssh-client \
      ca-certificates \
      ruby-dev \
      # pgStudio dependency:
      default-jdk \
 && gem install \
      bundler \
 && curl -sL https://deb.nodesource.com/setup_6.x | bash - \
 && apt-get update \
 && apt-get install -yq --no-install-recommends \
      # JupyterHub dependency:
      nodejs 


# Process Supervisor: s6-overlay 

RUN curl -sL https://github.com/just-containers/s6-overlay/releases/download/v1.11.0.1/s6-overlay-amd64.tar.gz | tar xz


# Open Science Libraries/Utilities

RUN apt-get install -yq --no-install-recommends \
      libgdal-dev \
      libudunits2-dev \
      libnlopt-dev \
      libgsl-dev \
      git \
 && git config --global push.default upstream
 

# R and RStudio

RUN apt-get install -yq --no-install-recommends \
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
RUN curl -sL http://ftp.debian.org/debian/pool/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u7_amd64.deb -o /tmp/libssl1.0.0.deb \
 && dpkg -i /tmp/libssl1.0.0.deb \
 && rm /tmp/libssl1.0.0.deb
RUN curl -sL https://download2.rstudio.org/rstudio-server-1.1.419-amd64.deb -o /tmp/rstudio.deb \
  && gdebi --non-interactive /tmp/rstudio.deb \
  && rm /tmp/rstudio.deb


# Python and JupyterLab

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
      jupyterlab \
      jupyterhub \
      jupyter-console \
      ipywidgets \
      bash_kernel \
 && jupyter serverextension enable --py jupyterlab --sys-prefix \
 && jupyter labextension install @jupyterlab/hub-extension \
 && jupyter labextension install @jupyterlab/geojson-extension \
 && python3 -m bash_kernel.install \
 && npm install -g \
      configurable-http-proxy

### FIXME prevent JupyterHub's username -> lowercase "normalization"
RUN sed -e "/username = username.lower()/d" -i /usr/local/lib/python3.5/dist-packages/jupyterhub/auth.py


# PostgreSQL

RUN apt-get install -yq --no-install-recommends \
      postgresql \
      postgresql-contrib \
 && usermod -a -G shadow postgres

## pgStudio (java requiremnt; software is in /usr/share/pgstudio)

RUN apt-get install -yq --no-install-recommends \
      default-jdk
        

# Packages for Building and Serving Lessons

RUN apt-get install -yq --no-install-recommends \
      ruby \
      emacs \
      rsync \
 && pip3 install \
      pweave \
      pyyaml \
      rise \
 && jupyter-nbextension install rise --py --sys-prefix \
 && jupyter-nbextension enable rise --py --sys-prefix


# Packages for Lessons

## R Packages

RUN echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl')" >> /usr/lib/R/etc/Rprofile.site \
 && Rscript -e "install.packages(c( \
      'evaluate', \
      'formatR', \
      'highr', \
      'markdown', \
      'yaml', \
      'caTools', \
      'bitops', \
      'knitr', \
      'base64enc', \
      'rprojroot', \
      'rmarkdown', \
      'codetools', \
      'gridExtra', \
      'RPostgreSQL', \
      'dbplyr', \
      'data.table', \
      'tidyr', \
      'tidytext', \
      'wordcloud', \
      'topicmodels', \
      'ggplot2', \
      'rgdal', \
      'readr', \
      'sf', \
      'leaflet', \
      'raster', \
      'stargazer', \
      'shiny', \
      'servr', \
      'lme4', \
      'tm', \
      'SnowballC', \
      'stringr', \
      'network'))" \
 && Rscript -e "install.packages('rstan', \
      repos = 'https://cloud.r-project.org/', \
      configure.args = 'CXXFLAGS=-O3 -mtune=native -march=native -Wno-unused-variable -Wno-unused-function -flto -ffat-lto-objects  -Wno-unused-local-typedefs -Wno-ignored-attributes -Wno-deprecated-declarations', \
      dependencies = TRUE)"

## Python Packages

RUN pip3 install \
      numpy \
      pandas \
      pygresql \
      sqlalchemy \
      lxml \
      beautifulsoup4 \
      requests \
      matplotlib \
      ggplot \
      census


# Data & Configuration

## For configuration of s6-overlay services (see root/etc/services.d)

ADD root /

## initialize postgresql, "student" role, and portal database

RUN service postgresql start \
 && su - postgres -c "psql -qc 'REVOKE ALL ON schema public FROM public'" \
 && su - postgres -c "createdb portal" \
 && su - postgres -c "createuser --no-login student" \
 && su - postgres -c "psql portal -qc 'ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO student'" \
 && su - postgres -c "psql portal -q < /var/backups/postgresql/portal_dump.sql" \
 && service postgresql stop \
 && sed -e "s|\(127.0.0.1/32\s*\)md5|\1pam pamservice=postgresql96|" -i /etc/postgresql/9.6/main/pg_hba.conf

### FIXEME PostgreSQL on linux host
### see https://github.com/docker/docker/issues/783#issuecomment-56013588
RUN mkdir /etc/ssl/private-copy \
 && mv /etc/ssl/private/* /etc/ssl/private-copy/ \
 && rm -r /etc/ssl/private \
 && mv /etc/ssl/private-copy /etc/ssl/private \
 && chmod -R 0700 /etc/ssl/private \
 && chown -R postgres /etc/ssl/private

## create /data volume
VOLUME /data

ENV USER=""

EXPOSE 80

ENTRYPOINT ["/init"]

## TODO
# Check permissions on home directory
# resolve makevar for root packages and this rstan thing
