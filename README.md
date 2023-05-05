# WRF, WPS, and WRF-4DVAR docker containers

These are container images for the [Weather and Research Forecasting](https://github.com/wrf-model/WRF)
model. The `wrf-wps` container contains the WRF and WPS programs, while the
`wrf-4dvar` container contains the WRF-4DVAR programs. They are
designed for use with [Common Workflow Language](https://www.commonwl.org/) (CWL) tool
descriptors and workflows.

## Requirements

* Docker (version 18.09 or later)

## Usage

### Tool descriptors

Tool descriptors are available in the [Atmospheric Tool Library](https://github.com/UoMResearchIT/atmos-tools-library).

Currently only tool descriptors for WRF and WPS are available. Tool descriptors
for WRF-4DVAR are not yet available.

### Workflows

Workflows using these tools are available on [WorkflowHub](https://workflowhub.eu/) in
the [Air Quality Prediction](https://workflowhub.eu/projects/103) group.

### Container Information

#### wrf-wps container

Executables are placed within the `/usr/local/bin` directory. WRF and WPS run directories
are provided within the container at `/WRF-run/` and `/WPS-run/`.

#### wrf-4dvar container

Executables are placed within the `/usr/local/bin` directory.

## Pre-built images

Images are available on the GitHub Container Repository:

* [wrf-wps](https://github.com/UoMResearchIT/wrf-docker/pkgs/container/wrf-wps) provides the main WRF and WPS applications
* [wrf-4dvar](https://github.com/UoMResearchIT/wrf-docker/pkgs/container/wrf-4dvar) provides the WRFPLUS and WRF-4DVar extensions

## Copyright & Licensing

### WRF

WRF was developed at the National Centre for Atmospheric Research (NCAR) and
released under an [open-source license](https://github.com/wrf-model/WRF/blob/master/LICENSE.txt).

### Docker scripts

The docker build scripts have been developed by the [Research IT](https://research-it.manchester.ac.uk/) 
department at the [University of Manchester](https://www.manchester.ac.uk/).

Copyright 2023 [University of Manchester, UK](https://www.manchester.ac.uk/).

Licensed under the MIT license, see the LICENSE file for details.
