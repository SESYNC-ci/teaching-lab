FROM debian:stretch-slim
MAINTAINER "Ian Carroll" icarroll@sesync.org

## FIXME update-alternatives to blame for this one
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
      wget \
      gnupg2 \
      openssh-client \
      ca-certificates \
      ruby-dev \
      cron \
      procps
      
# Open Science Libraries/Utilities

RUN apt-get install -yq --no-install-recommends \
      libgdal-dev \
      python-gdal \
      libudunits2-dev \
      libnlopt-dev \
      libgsl-dev \
      git \
      libcairo2-dev \
      libmagick++-dev \
      libspatialindex-c4v5 \
      pandoc \
 && git config --global push.default upstream
