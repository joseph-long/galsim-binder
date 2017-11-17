#!/bin/sh
set -e
SCRIPTDIR="$(cd "$(dirname "$1")"; pwd -P)"
docker build -t galsim-binder .
docker run --mount type=bind,src=$SCRIPTDIR/notebooks,dst=/home/jovyan/notebooks -p 127.0.0.1:8888:8888 galsim-binder
