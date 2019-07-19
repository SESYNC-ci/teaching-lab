FROM sesync/lab-debian
MAINTAINER "Ian Carroll" icarroll@sesync.org


# System Configuration

ADD root /
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - \
 && apt-get update \
 && apt-get install -yq --no-install-recommends \
      python3 \
      python3-dev \
      python3-pip \
      python3-gdal \
      nodejs 


# Python and JupyterLab

RUN python3 -m pip install --upgrade pip \
 && python3 -m pip install \
      setuptools \
      wheel \
 && python3 -m pip install \
      tornado \
      jinja2 \
      traitlets \
      jupyter \
      jupyterlab \
      jupyterhub \
      jupyter-console \
      ipywidgets \
      bash_kernel
RUN npm install -g \
      configurable-http-proxy \
 && jupyter serverextension enable --py jupyterlab --sys-prefix \
 && jupyter labextension install @jupyterlab/hub-extension \
# && jupyter labextension install @jupyterlab/geojson-extension
 && python3 -m bash_kernel.install


# Packages for Lessons

RUN python3 -m pip install \
      beautifulsoup4 \
      cartopy \
      census \
      descartes \
      esda \
      geopandas \
      georasters \
      ggplot \
      libpysal \
      lxml \
      matplotlib \
      mlxtend \
      numpy \
      pandas \
      pygresql \
      pysal \
      pydap \
      pyproj \
      rasterio \
      requests \
      seaborn \
      shapely \
      sqlalchemy \
      scikit-learn \
      scipy \
      seaborn \
      splot \
      webcolors


# Docker Configuration

VOLUME /home
VOLUME /nfs

CMD ["/usr/local/bin/jupyterhub", "-f", "/etc/jupyterhub/jupyterhub_config.py"]

# # TODO
# # jupyterlab_iframe
