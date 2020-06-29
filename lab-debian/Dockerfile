FROM debian:buster-slim
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
      rsync \
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
      git \
      libgdal-dev \
      libudunits2-dev \
      libnlopt-dev \
      libgsl-dev \
      libcairo2-dev \
      libmagick++-dev \
      libspatialindex-c4v5 \
      pandoc \
      postgresql-client \
      libjq-dev \
      librdf0-dev \
      python3 \
 && git config --system push.default upstream \
 && git config --system credential.helper "cache --timeout 100000"
