FROM jupyter/scipy-notebook@7fd175ec22c7
MAINTAINER Joseph Long <help@stsci.edu>

# Note: this is ordered roughly by how often things are expected
# to change (ascending). That way, only the last few changed steps
# are rebuilt on push.

WORKDIR $HOME

# As root:
USER root

# Install distro packages for dependencies
ENV APT_EXTRA_PACKAGES libfftw3-dev scons libblas-dev liblapack-dev gfortran
RUN apt-get update \
 && apt-get install -yq --no-install-recommends $APT_EXTRA_PACKAGES \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install TMV (custom linear algebra library) from source
RUN wget -qO- https://github.com/rmjarvis/tmv/archive/v0.73.tar.gz | tar xvz
RUN cd tmv-0.73 && sudo scons install

# As a normal user:
USER $NB_USER

# Prepare environment variables
ENV PYHOME /opt/conda
ENV PYTHON_VERSION 3.6
ENV PATH $HOME/bin:$PATH
ENV LD_LIBRARY_PATH $HOME/lib:$LD_LIBRARY_PATH

# Enable conda-forge package list
RUN conda config --add channels conda-forge

# Install GalSim dependencies for python3
# from conda:
ENV EXTRA_PACKAGES astropy future pyyaml pandas boost
RUN conda install --yes $EXTRA_PACKAGES && \
    conda clean -tipsy
# from pip:
RUN pip install --no-cache-dir starlink-pyast

# Obtain GalSim
ENV GALSIM_RELEASE releases/1.5
RUN git clone -b $GALSIM_RELEASE --depth=1 https://github.com/GalSim-developers/GalSim.git $HOME/galsim
WORKDIR $HOME/galsim
# Build GalSim
RUN scons \
    PREFIX=$HOME \
    PYTHON=$PYHOME/bin/python \
    PYPREFIX=$PYHOME/lib/python$PYTHON_VERSION/site-packages \
    BOOST_DIR=$PYHOME && \
    scons install
WORKDIR $HOME

# Copy notebooks into place
# (n.b. This must be last because otherwise Dockerfile edits
# invalidate the build cache)
COPY . $HOME
