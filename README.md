# wrf-docker

This build system creates a docker container for WRF / WPS.

Main page: https://github.com/wrf-model/WRF

## Requirements

* Docker (version 18.09 or later)

## Pre-built images

Images are available at the Dockerhub:

* [wrf-wps](https://github.com/UoMResearchIT/wrf-docker/pkgs/container/wrf-wps) provides the main WRF application
* [wrf-4dvar](https://github.com/UoMResearchIT/wrf-docker/pkgs/container/wrf-4dvar) provides the WRFPLUS and WRF-4DVar extensions


## Usage

These containers are built on the [WRF software library container](https://github.com/UoMResearchIT/wrf-software-libraries-docker/pkgs/container/wrf-libraries).

To build the containers use these commands:
* `DOCKER_BUILDKIT=1 docker build . -t 'wrf_wps' -f Dockerfile-wrf_wps`
* `DOCKER_BUILDKIT=1 docker build . -t 'wrfplus_4dvar' -f Dockerfile-wrfplus_4dvar`
