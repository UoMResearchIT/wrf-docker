#RUN git clone https://github.com/whatheway/WRF-4.3.3-install-script-linux-64bit.git wrf-install-scripts

FROM ubuntu:20.04

###############################################################################
## Install requirements

RUN apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC \
                      apt-get install -y \ 
                                      nano \
                                      git \
                                      wget \
                                      gcc \
                                      gfortran \                            
                                      g++ \                                 
                                      libtool \
                                      automake \
                                      autoconf \
                                      make \
                                      m4 \
                                      default-jre \
                                      default-jdk \
                                      csh \
                                      ksh \
                                      zip \
                                      cmake \
                                      ncview \
                                      ncl-ncarg \
                                      python3

###############################################################################
## Set directory variables

ENV WRF_SOURCES=/WRF-SOURCES
ENV WRF_PREFIX=/usr/local
ENV WRF_LIB=$WRF_PREFIX/lib
ENV WRF_INC=$WRF_PREFIX/include

ENV LD_LIBRARY_PATH=$WRF_LIB

###############################################################################
## Install zlib v1.2.11

WORKDIR $WRF_SOURCES

ARG TARGET_URL=https://github.com/madler/zlib/archive/refs/tags/v1.2.11.tar.gz
ARG TARGET=zlib
ARG EXTRA_FLAGS=

WORKDIR $TARGET
RUN wget -c $TARGET_URL -O $TARGET.tar.gz

RUN mkdir $TARGET-src
RUN tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

WORKDIR $TARGET-build
RUN ../$TARGET-src/configure $EXTRA_FLAGS
RUN make -j$(nproc)
RUN make install
#RUN make check

###############################################################################
## Install libpng

WORKDIR $WRF_SOURCES

ARG TARGET_URL=https://download.sourceforge.net/libpng/libpng-1.6.37.tar.gz
ARG TARGET=libpng
ARG EXTRA_FLAGS=

WORKDIR $TARGET
RUN wget -c $TARGET_URL -O $TARGET.tar.gz

RUN mkdir $TARGET-src
RUN tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

WORKDIR $TARGET-build
RUN ../$TARGET-src/configure --prefix=$WRF_PREFIX $EXTRA_FLAGS
RUN make -j$(nproc)
RUN make install
#RUN make check

###############################################################################
## Install JasPer

ARG TARGET_URL=https://github.com/jasper-software/jasper/releases/download/version-3.0.3/jasper-3.0.3.tar.gz
ARG TARGET=jasper

WORKDIR $TARGET
RUN wget -c $TARGET_URL -O $TARGET.tar.gz

RUN mkdir $TARGET-src
RUN tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

WORKDIR $TARGET-build
RUN cmake ../$TARGET-src/
RUN make -j$(nproc)
RUN make install
#RUN make check

ENV JASPERLIB=$WRF_LIB
ENV JASPERINC=$WRF_INC

###############################################################################
## Install hdf5

WORKDIR $WRF_SOURCES

ARG TARGET_URL=https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5-1_13_1.tar.gz
ARG TARGET=hdf5
ARG EXTRA_FLAGS="--enable-hl --enable-fortran"

WORKDIR $TARGET
RUN wget -c $TARGET_URL -O $TARGET.tar.gz

RUN mkdir $TARGET-src
RUN tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

WORKDIR $TARGET-build
RUN ../$TARGET-src/configure --prefix=$WRF_PREFIX $EXTRA_FLAGS
RUN make -j$(nproc)
RUN make install
#RUN make check

ENV HDF5=$WRF_PREFIX

###############################################################################
## Install NETCDF C library

WORKDIR $WRF_SOURCES

ARG TARGET_URL=https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.8.1.tar.gz
ARG TARGET=netcdf-c
ARG EXTRA_FLAGS=--disable-dap

WORKDIR $TARGET
RUN wget -c $TARGET_URL -O $TARGET.tar.gz

RUN mkdir $TARGET-src
RUN tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

WORKDIR $TARGET-build
RUN ../$TARGET-src/configure --prefix=$WRF_PREFIX $EXTRA_FLAGS
RUN make -j$(nproc)
RUN make install
#RUN make check

###############################################################################
## Install NETCDF Fortran library

WORKDIR $WRF_SOURCES

ARG TARGET_URL=https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v4.5.4.tar.gz
ARG TARGET=netcdf-fortran
ARG EXTRA_FLAGS=--disable-shared

WORKDIR $TARGET
RUN wget -c $TARGET_URL -O $TARGET.tar.gz

RUN mkdir $TARGET-src
RUN tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

WORKDIR $TARGET-build
RUN ../$TARGET-src/configure --prefix=$WRF_PREFIX $EXTRA_FLAGS
RUN make -j$(nproc)
RUN make install
#RUN make check

###############################################################################
## Install MPICH

WORKDIR $WRF_SOURCES

ARG TARGET_URL=https://github.com/pmodels/mpich/releases/download/v4.0.2/mpich-4.0.2.tar.gz
ARG TARGET=mpich
ARG EXTRA_FLAGS=--with-device=ch3

WORKDIR $TARGET
RUN wget -c $TARGET_URL -O $TARGET.tar.gz

RUN mkdir $TARGET-src
RUN tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

WORKDIR $TARGET-build
RUN ../$TARGET-src/configure --prefix=$WRF_PREFIX $EXTRA_FLAGS
RUN make -j$(nproc)
RUN make install
#RUN make check

###############################################################################
## Install NCEPlibs using install script

WORKDIR $WRF_SOURCES

ARG TARGET_URL=https://github.com/NCAR/NCEPlibs.git
ARG TARGET=ncep
ARG EXTRA_FLAGS=

RUN git clone $TARGET_URL $TARGET
WORKDIR $TARGET
RUN mkdir nceplibs

ARG JASPER_INC=$WRF_PREFIX/include
ARG PNG_INC=$WRF_PREFIX/include
ARG NETCDF=$WRF_PREFIX/
ARG NCEPLIBS_DIR=$(pwd)/nceplibs

RUN printf 'y\n' | ./make_ncep_libs.sh -s linux -c gnu -d ./nceplibs -o 0 -m 1 -a upp

###############################################################################
# Install UPP

WORKDIR $WRF_SOURCES

ARG TARGET_URL=https://github.com/NOAA-EMC/UPP.git
ARG TARGET=upp
ARG EXTRA_FLAGS=

WORKDIR $TARGET
RUN git clone -b dtc_post_v4.1.0 --recurse-submodules $TARGET_URL $TARGET-src

WORKDIR $TARGET-src
RUN printf '8\n' | ./configure
RUN ./compile

###############################################################################
## Install ARWpost

WORKDIR $WRF_SOURCES

ARG TARGET_URL=http://www2.mmm.ucar.edu/wrf/src/ARWpost_V3.tar.gz
ARG TARGET=ARWpost
ARG EXTRA_FLAGS=

WORKDIR $TARGET
RUN wget -c $TARGET_URL -O $TARGET.tar.gz

RUN mkdir $TARGET-src
RUN tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

WORKDIR $TARGET-src
RUN sed -i -e 's/-lnetcdf/-lnetcdff -lnetcdf/g' src/Makefile
RUN printf '3\n' | ./configure $EXTRA_FLAGS
RUN sed -i -e 's/-C -P/-P/g' configure.arwp
RUN ./compile

###############################################################################
## Install OpenGrADS

WORKDIR $WRF_SOURCES
ARG MAIN_TARGET=GrADS
RUN mkdir -p $WRF_PREFIX/$MAIN_TARGET/Contents

## Main tar

ARG TARGET_URL=https://sourceforge.net/projects/opengrads/files/grads2/2.2.1.oga.1/Linux%20%2864%20Bits%29/opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz
ARG TARGET=GrADS
ARG EXTRA_FLAGS=

WORKDIR $TARGET
RUN wget -c $TARGET_URL -O $TARGET.tar.gz

RUN mkdir $TARGET-src
RUN tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

RUN mv $TARGET-src/* $WRF_PREFIX/$MAIN_TARGET

## g2ctl

WORKDIR $WRF_SOURCES

ARG TARGET_URL=ftp://ftp.cpc.ncep.noaa.gov/wd51we/g2ctl/g2ctl
ARG TARGET=g2ctl
ARG EXTRA_FLAGS=

WORKDIR $TARGET
RUN wget -c $TARGET_URL -O $TARGET

RUN mv $TARGET $WRF_PREFIX/$MAIN_TARGET/Contents

## wgrib2

WORKDIR $WRF_SOURCES

ARG TARGET_URL=https://sourceforge.net/projects/opengrads/files/wgrib2/0.1.9.4/wgrib2-v0.1.9.4-bin-x86_64-glibc2.5-linux-gnu.tar.gz
ARG TARGET=wgrib2
ARG EXTRA_FLAGS=

WORKDIR $TARGET
RUN wget -c $TARGET_URL -O $TARGET.tar.gz

RUN mkdir $TARGET-src
RUN tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

RUN mv $TARGET-src/bin/wgrib2 $WRF_PREFIX/$MAIN_TARGET/Contents

###############################################################################
## Install WRF v4.3.3

WORKDIR $WRF_SOURCES
ARG MAIN_TARGET=WRF

## WRF

WORKDIR $WRF_SOURCES

ARG TARGET_URL=https://github.com/wrf-model/WRF/archive/v4.3.3.tar.gz 
ARG TARGET=WRF
ARG EXTRA_FLAGS=

WORKDIR $TARGET
RUN wget -c $TARGET_URL -O $TARGET.tar.gz

RUN mkdir $TARGET-src
RUN tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

WORKDIR $TARGET-src
RUN printf '34\n1\n' | ./configure $EXTRA_FLAGS
RUN ./compile em_real

RUN mkdir $WRF_PREFIX/$MAIN_TARGET
RUN cp -r ./* $WRF_PREFIX/$MAIN_TARGET
ARG WRF_DIR=$WRF_PREFIX/$MAIN_TARGET

###############################################################################
## Install WPS

WORKDIR $WRF_SOURCES

ARG TARGET_URL=https://github.com/wrf-model/WPS/archive/refs/tags/v4.3.1.tar.gz
ARG TARGET=WPS
ARG EXTRA_FLAGS=

WORKDIR $TARGET
RUN wget -c $TARGET_URL -O $TARGET.tar.gz

RUN mkdir $TARGET-src
RUN tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

WORKDIR $TARGET-src
RUN printf '3\n' | ./configure $EXTRA_FLAGS
RUN ./compile $EXTRA_FLAGS

###############################################################################
## Install WPSPLUS 

WORKDIR $WRF_SOURCES

ARG TARGET_URL=https://github.com/wrf-model/WRF/archive/v4.3.3.tar.gz 
ARG TARGET=WRFPLUS
ARG EXTRA_FLAGS=wrfplus

WORKDIR $TARGET
RUN wget -c $TARGET_URL -O $TARGET.tar.gz

RUN mkdir $TARGET-src
RUN tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

WORKDIR $TARGET-src
RUN printf '18\n' | ./configure $EXTRA_FLAGS
RUN ./compile $EXTRA_FLAGS

ARG WRFPLUS_DIR=$WRF_PREFIX/$TARGET

###############################################################################
## Install WPSPLUS 4DVAR

WORKDIR $WRF_SOURCES

ARG TARGET_URL=https://github.com/wrf-model/WRF/archive/v4.3.3.tar.gz 
ARG TARGET=WRFPLUS_4D
ARG EXTRA_FLAGS=

WORKDIR $TARGET
RUN wget -c $TARGET_URL -O $TARGET.tar.gz

RUN mkdir $TARGET-src
RUN tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

WORKDIR $TARGET-src
RUN printf '18\n' | ./configure 4dvar
RUN ./compile all_wrfvar
