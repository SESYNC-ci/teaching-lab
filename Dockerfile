FROM rocker/rstudio:latest
MAINTAINER "Ian Carroll" icarroll@sesync.org

# Remove rocker/rstudio s6-overlay init scripts
RUN rm -rf /etc/cont-init.d

# Installation steps

## base packages
ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
    build-essential \
    apt-utils \
    curl \
    gnupg2 \
    nginx

## add NodeSource repository and nodejs (JupyterHub requirement)
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
    nodejs

## OSGeo
RUN apt-get install -yq --no-install-recommends \
    libgdal-dev

## R packages
RUN Rscript -e 'install.packages(c( \
    "rgdal", \
    "shiny"))'

## JupyterHub and Python packages
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

## pgStudio (java requiremnt; software is in /usr/share/pgstudio)
RUN apt-get install -yq --no-install-recommends \
    default-jdk
        
## PostgreSQL
RUN apt-get install -yq --no-install-recommends \
    postgresql \
    postgresql-contrib

# Data & Configuration steps

## includes configuration for s6-overlay services (see root/etc/services.d)
ADD root /

## Initialize postgresql and add Portal Mammals database, owned by "student"
RUN service postgresql start && \
    su - postgres -c "createuser --no-login student" && \
    su - postgres -c "createdb portal -O student" && \
    su - postgres -c "psql -q portal < /var/backups/postgresql/portal_dump.sql" && \
    service postgresql stop

## Use PAM authentication based on system users (see also /etc/cont-init.d/userconf)
RUN usermod -a -G shadow postgres && \
    sed -e "s|\(127.0.0.1/32\s*\)md5|\1pam pamservice=postgresql96|" -i /etc/postgresql/9.6/main/pg_hba.conf

## add an empty "network file storage" for user data
VOLUME /share

EXPOSE 80

ENTRYPOINT ["/init"]

## ideas
# use gitlab pages as web server and git 'origin'?
# ssh-keygen: could put a private ssh key in the docker file, for GitHub ... but maybe not needed without the handouts repo.
# what does user namespaces on docker allow?
# curl/clone the handouts repo?
# if everyone "imports" the handouts on GitHub, then clones locally with data - they can all push to share solutions, and handouts are within /home/username/reponame
# would be tidy to remove the /home/rstudio/kitematic ...

## fixmes
# [ ] ERROR: dependency ‘jsonlite’ is not available for package ‘shiny’
# [ ] R packages cairo and rgdal not installing?, missing cairo.h and proj_api.h. Maybe taken care of by removing dependencies.

## todo
# [x] jupyterhub
# [x] postgresql
# [x] pgstudio
# [ ] R packages
# [ ] Python modules
