FROM jupyter/scipy-notebook

MAINTAINER Joseph Long <help@stsci.edu>

WORKDIR $HOME

USER root

# Enable backports so we can install ffmpeg (GalSim dependency)
# Okay, it looks like there is only one (oblique) reference to ffmpeg in
# https://github.com/GalSim-developers/GalSim/blob/a655e0ff687e49a751faf1b966688af9d6fec1e6/examples/psf_wf_movie.py#L134
# So we can maybe get away without enabling jessie backports just for that.
# RUN REPO=http://cdn-fastly.deb.debian.org \
#  && echo "deb $REPO/debian jessie main\ndeb $REPO/debian-security jessie/updates main\ndeb $REPO/debian jessie-backports main" > /etc/apt/sources.list \
#  && apt-get update && apt-get -yq dist-upgrade \
#  && apt-get install -yq --no-install-recommends \
#     libfftw3-dev scons libblas-dev liblapack-dev gfortran ffmpeg \
#  && apt-get clean \
#  && rm -rf /var/lib/apt/lists/*

ENV APT_EXTRA_PACKAGES libfftw3-dev scons libblas-dev liblapack-dev gfortran

RUN apt-get update \
 && apt-get install -yq --no-install-recommends $APT_EXTRA_PACKAGES \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

ENV PYHOME /opt/conda
ENV PYTHON_VERSION 3.6
ENV PATH $HOME/bin:$PATH
ENV LD_LIBRARY_PATH $HOME/lib:$LD_LIBRARY_PATH

# Fix a directory name in 3.x installations so boost can find it.
# RUN if test -d $PYHOME/include/python$PYTHON_VERSIONm; \
#     then ln -s $PYHOME/include/python$PYTHON_VERSIONm \
#                $PYHOME/include/python$PYTHON_VERSION; \
#     fi

RUN wget -qO- https://github.com/rmjarvis/tmv/archive/v0.73.tar.gz | tar xvz
RUN cd tmv-0.73 && sudo scons install

USER $NB_USER

# Note: this Dockerfile is ordered roughly by how often things are expected
# to change (ascending). That way, only the last few changed steps are
# rebuilt on push.

# Configure AstroConda
RUN conda config --system --add channels http://ssb.stsci.edu/astroconda

# Install GalSim dependencies for python2 and python3
# from conda:
ENV EXTRA_PACKAGES astropy future pyyaml pandas boost
RUN conda install --yes $EXTRA_PACKAGES && \
    conda remove  --yes --force qt pyqt && \
    conda clean -tipsy
RUN conda install --yes -n python2 $EXTRA_PACKAGES && \
    conda remove  --yes -n python2 --force qt pyqt && \
    conda clean -tipsy
# from pip:
RUN pip3 install --no-cache-dir starlink-pyast
RUN pip2 install --no-cache-dir starlink-pyast

# Obtain GalSim
RUN git clone --depth=1 https://github.com/GalSim-developers/GalSim.git $HOME/galsim
WORKDIR $HOME/galsim

# Build GalSim
RUN scons \
    PREFIX=$HOME \
    PYTHON=$PYHOME/bin/python \
    PYPREFIX=$PYHOME/lib/python$PYTHON_VERSION/site-packages \
    BOOST_DIR=$PYHOME && \
    scons install

# Copy notebooks into place
COPY . $HOME