# wrf-docker

This build system creates a docker container for WRF / WPS.

Main page: https://github.com/wrf-model/WRF

## Requirements

* Docker (version 18.09 or later)

## Usage

Begin with building the base container, this needs to be named `wrf_intermediate`:
* `DOCKER_BUILDKIT=1 docker build . -t 'wrf_intermediate' -f Dockerfile-base`

After this the main containers can be built, based on the `wrf_intermediate` container:
* `DOCKER_BUILDKIT=1 docker build . -t 'wrf_wps' -f Dockerfile-wrf_wps`
* `DOCKER_BUILDKIT=1 docker build . -t 'wrfplus_4dvar' -f Dockerfile-wrfplus_4dvar`
