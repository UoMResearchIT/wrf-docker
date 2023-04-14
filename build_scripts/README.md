# wrf-docker

This build system creates docker containers for WRF.

There are scripts for building two containers:
1. WRF & WPS combined container
2. WRF-4VAR container

Main page: https://github.com/wrf-model/WRF

## Requirements

* Docker (version 18.09 or later)

## Usage

These containers are built on the [WRF software library container](https://github.com/UoMResearchIT/wrf-software-libraries-docker/pkgs/container/wrf-libraries).

To build the WRF/WPS container use these commands:
* `DOCKER_BUILDKIT=1 docker build . -t 'wrf_final' -f Dockerfile-wrf_wps`
* `docker image tag wrf_final ghcr.io/uomresearchit/wrf-wps:latest`
* `docker image tag wrf_final ghcr.io/uomresearchit/wrf-wps:<WRF version>`

To build the WRF-4DVAR container use these commands:
* `DOCKER_BUILDKIT=1 docker build . -t 'wrfplus_4dvar' -f Dockerfile-wrfplus_4dvar`
* `docker image tag wrfplus_4dvar ghcr.io/uomresearchit/wrf-4dvar:latest`
* `docker image tag wrfplus_4dvar ghcr.io/uomresearchit/wrf-4dvar:<WRF version>`

