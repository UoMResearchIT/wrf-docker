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
RUN wget -c $TARGET_URL -O $TARGET.tar.gz && \
    mkdir $TARGET-src && \
    tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

WORKDIR $TARGET-build
RUN ../$TARGET-src/configure $EXTRA_FLAGS && \
    make -j$(nproc) && \
    make install

###############################################################################
## Install libpng

WORKDIR $WRF_SOURCES

ARG TARGET_URL=https://download.sourceforge.net/libpng/libpng-1.6.37.tar.gz
ARG TARGET=libpng
ARG EXTRA_FLAGS=

WORKDIR $TARGET
RUN wget -c $TARGET_URL -O $TARGET.tar.gz && \
    mkdir $TARGET-src && \
    tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

WORKDIR $TARGET-build
RUN ../$TARGET-src/configure --prefix=$WRF_PREFIX $EXTRA_FLAGS && \
    make -j$(nproc) && \
    make install

###############################################################################
## Install JasPer

WORKDIR $WRF_SOURCES

ARG TARGET_URL=https://github.com/jasper-software/jasper/releases/download/version-2.0.33/jasper-2.0.33.tar.gz
ARG TARGET=jasper
ARG EXTRA_FLAGS=

WORKDIR $TARGET
RUN wget -c $TARGET_URL -O $TARGET.tar.gz && \
    mkdir $TARGET-src && \
    tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

WORKDIR $TARGET-build
RUN cmake -DJAS_ENABLED_SHARED=true -DJAS_ENABLE_LIBJPEG=true ../$TARGET-src/ && \
    make -j$(nproc) && \
    make install

ENV JASPERLIB=$WRF_LIB
ENV JASPERINC=$WRF_INC

###############################################################################
## Install hdf5

WORKDIR $WRF_SOURCES

ARG TARGET_URL=https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5-1_13_1.tar.gz
ARG TARGET=hdf5
ARG EXTRA_FLAGS="--enable-hl --enable-fortran"

WORKDIR $TARGET
RUN wget -c $TARGET_URL -O $TARGET.tar.gz && \
    mkdir $TARGET-src && \
    tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

WORKDIR $TARGET-build
RUN ../$TARGET-src/configure --prefix=$WRF_PREFIX $EXTRA_FLAGS && \
    make -j$(nproc) && \
    make install

ENV HDF5=$WRF_PREFIX

###############################################################################
## Install NETCDF C library

WORKDIR $WRF_SOURCES

ARG TARGET_URL=https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.8.1.tar.gz
ARG TARGET=netcdf-c
ARG EXTRA_FLAGS=--disable-dap

WORKDIR $TARGET
RUN wget -c $TARGET_URL -O $TARGET.tar.gz && \
    mkdir $TARGET-src && \
    tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

WORKDIR $TARGET-build
RUN ../$TARGET-src/configure --prefix=$WRF_PREFIX $EXTRA_FLAGS && \
    make -j$(nproc) && \
    make install

###############################################################################
## Install NETCDF Fortran library

WORKDIR $WRF_SOURCES

ARG TARGET_URL=https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v4.5.4.tar.gz
ARG TARGET=netcdf-fortran
ARG EXTRA_FLAGS=--disable-shared

WORKDIR $TARGET
RUN wget -c $TARGET_URL -O $TARGET.tar.gz && \
    mkdir $TARGET-src && \
    tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

WORKDIR $TARGET-build
RUN ../$TARGET-src/configure --prefix=$WRF_PREFIX $EXTRA_FLAGS && \
    make -j$(nproc) && \
    make install

###############################################################################
## Install MPICH

WORKDIR $WRF_SOURCES

ARG TARGET_URL=https://github.com/pmodels/mpich/releases/download/v4.0.2/mpich-4.0.2.tar.gz
ARG TARGET=mpich
ARG EXTRA_FLAGS=--with-device=ch3

WORKDIR $TARGET
RUN wget -c $TARGET_URL -O $TARGET.tar.gz && \
    mkdir $TARGET-src && \
    tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

WORKDIR $TARGET-build
RUN ../$TARGET-src/configure --prefix=$WRF_PREFIX $EXTRA_FLAGS && \
    make -j$(nproc) && \
    make install

###############################################################################
## general arguments

ARG JASPER_INC=$WRF_PREFIX/include
ARG PNG_INC=$WRF_PREFIX/include
ARG NETCDF=$WRF_PREFIX/

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
RUN wget -c $TARGET_URL -O $TARGET.tar.gz && \
    mkdir $TARGET-src && \
    tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

WORKDIR $TARGET-src
RUN printf '34\n1\n' | ./configure $EXTRA_FLAGS && ./compile em_real

RUN mkdir $WRF_PREFIX/$MAIN_TARGET && \
    cp -r ./* $WRF_PREFIX/$MAIN_TARGET

ARG WRF_DIR=$WRF_PREFIX/$MAIN_TARGET

###############################################################################
## Install WPS

WORKDIR $WRF_SOURCES

ARG TARGET_URL=https://github.com/wrf-model/WPS/archive/refs/tags/v4.3.1.tar.gz
ARG TARGET=WPS
ARG EXTRA_FLAGS=

WORKDIR $TARGET
RUN wget -c $TARGET_URL -O $TARGET.tar.gz && \
    mkdir $TARGET-src && \
    tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

WORKDIR $TARGET-src
RUN printf '3\n' | ./configure $EXTRA_FLAGS && ./compile $EXTRA_FLAGS

###############################################################################
## Install WPSPLUS 

WORKDIR $WRF_SOURCES

ARG TARGET_URL=https://github.com/wrf-model/WRF/archive/v4.3.3.tar.gz 
ARG TARGET=WRFPLUS
ARG EXTRA_FLAGS=wrfplus

WORKDIR $TARGET
RUN wget -c $TARGET_URL -O $TARGET.tar.gz && \
    mkdir $TARGET-src && \
    tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

WORKDIR $TARGET-src
RUN printf '18\n' | ./configure $EXTRA_FLAGS && ./compile $EXTRA_FLAGS

ARG WRFPLUS_DIR=$WRF_PREFIX/$TARGET

###############################################################################
## Install WPSPLUS 4DVAR

WORKDIR $WRF_SOURCES

ARG TARGET_URL=https://github.com/wrf-model/WRF/archive/v4.3.3.tar.gz 
ARG TARGET=WRFPLUS_4D
ARG EXTRA_FLAGS=

WORKDIR $TARGET
RUN wget -c $TARGET_URL -O $TARGET.tar.gz && \
    mkdir $TARGET-src && \
    tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

WORKDIR $TARGET-src
RUN printf '18\n' | ./configure 4dvar && ./compile all_wrfvar
