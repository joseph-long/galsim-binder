# galsim-binder

The [Binder](http://mybinder.org) service allows people to experiment with scientific software in temporary cloud environments.

This repository includes the necessary instructions to set up an environment with the GalSim simulation toolkit (version 1.4.4) and an example notebook showcasing the WFIRST simulation capabilities of the toolkit.

## Launch in the cloud with Binder

To launch in Binder *(beta)*, click here: [![Binder](https://mybinder.org/badge.svg)](https://mybinder.org/v2/gh/joseph-long/galsim-binder/master)

## Run locally

1. Start by installing the free [Docker Community Edition](https://www.docker.com/community-edition) locally. This will make the `docker` command available in your terminal.
2. Clone this repository to a folder on your computer and `cd` into it.
3. Execute `./run.sh` to build and start a Docker container. You should see a lot of output, ending with something like:

   ```
   [C 12:34:56.000 NotebookApp]

       Copy/paste this URL into your browser when you connect for the first time,
       to login with a token:
           http://localhost:8888/?token=aabbccddeeff00112233445566778899
   ```

  Open that URL in a browser, and you'll see a Jupyter notebook interface to an environment with `galsim` available. (The `run.sh` script forwards `localhost:8888` to the same port in the container, so you can copy the URL as-is.)
