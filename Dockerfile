# syntax=docker/dockerfile:1.4.2

FROM ubuntu:20.04

###############################################################################
## Install requirements

RUN apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC \
                      apt-get install -y \ 
                                      wget \
                                      gcc \
                                      gfortran \                            
                                      g++ \                                 
                                      libtool \
                                      automake \
                                      autoconf \
                                      make \
                                      m4 \
                                      csh \
                                      zip \
                                      cmake \
                                      python3

###############################################################################
## Set directory variables

ENV WRF_SOURCES=/WRF-SOURCES
ENV WRF_PREFIX=/usr/local
ENV WRF_LIB=$WRF_PREFIX/lib
ENV WRF_INC=$WRF_PREFIX/include

ENV LD_LIBRARY_PATH=$WRF_LIB

## create working directory, and change to this location
WORKDIR $WRF_SOURCES


###############################################################################
## Install zlib v1.2.11

WORKDIR $WRF_SOURCES

ARG TARGET_URL=https://github.com/madler/zlib/archive/refs/tags/v1.2.11.tar.gz
ARG TARGET=zlib
ARG EXTRA_FLAGS=

RUN <<EOF_ZLIB
mkdir $TARGET
cd $TARGET

wget -c $TARGET_URL -O $TARGET.tar.gz
mkdir $TARGET-src
tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

mkdir $TARGET-build
cd $TARGET-build

../$TARGET-src/configure $EXTRA_FLAGS
make -j$(nproc)
make install

cd $WRF-SOURCES
rm -rf $TARGET
EOF_ZLIB


###############################################################################
## Install libpng

WORKDIR $WRF_SOURCES

ARG TARGET_URL=https://download.sourceforge.net/libpng/libpng-1.6.37.tar.gz
ARG TARGET=libpng
ARG EXTRA_FLAGS=

RUN <<EOF_LIBPNG
mkdir $TARGET
cd $TARGET

wget -c $TARGET_URL -O $TARGET.tar.gz
mkdir $TARGET-src
tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

mkdir $TARGET-build
cd $TARGET-build

../$TARGET-src/configure --prefix=$WRF_PREFIX $EXTRA_FLAGS
make -j$(nproc) && \
make install

cd $WRF-SOURCES
rm -rf $TARGET
EOF_LIBPNG

###############################################################################
## Install JasPer

WORKDIR $WRF_SOURCES

ARG TARGET_URL=https://github.com/jasper-software/jasper/releases/download/version-2.0.33/jasper-2.0.33.tar.gz
ARG TARGET=jasper
ARG EXTRA_FLAGS=

RUN <<EOF_JASPER
mkdir $TARGET
cd $TARGET

wget -c $TARGET_URL -O $TARGET.tar.gz
mkdir $TARGET-src
tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

mkdir $TARGET-build
cd $TARGET-build
cmake -DJAS_ENABLED_SHARED=true -DJAS_ENABLE_LIBJPEG=true ../$TARGET-src/
make -j$(nproc)
make install

cd $WRF-SOURCES
rm -rf $TARGET
EOF_JASPER

ENV JASPERLIB=$WRF_LIB
ENV JASPERINC=$WRF_INC

###############################################################################
## Install hdf5

WORKDIR $WRF_SOURCES

ARG TARGET_URL=https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5-1_13_1.tar.gz
ARG TARGET=hdf5
ARG EXTRA_FLAGS="--enable-hl --enable-fortran"

RUN <<EOF_HDF5
mkdir $TARGET
cd $TARGET

wget -c $TARGET_URL -O $TARGET.tar.gz
mkdir $TARGET-src
tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

mkdir $TARGET-build
cd $TARGET-build
../$TARGET-src/configure --prefix=$WRF_PREFIX $EXTRA_FLAGS
make -j$(nproc)
make install

cd $WRF-SOURCES
rm -rf $TARGET 
EOF_HDF5

ENV HDF5=$WRF_PREFIX

###############################################################################
## Install NETCDF C library

WORKDIR $WRF_SOURCES

ARG TARGET_URL=https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.8.1.tar.gz
ARG TARGET=netcdf-c
ARG EXTRA_FLAGS=--disable-dap

RUN <<EOF_NETC
mkdir $TARGET
cd $TARGET

wget -c $TARGET_URL -O $TARGET.tar.gz
mkdir $TARGET-src
tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

mkdir $TARGET-build
cd $TARGET-build
../$TARGET-src/configure --prefix=$WRF_PREFIX $EXTRA_FLAGS
make -j$(nproc)
make install

cd $WRF-SOURCES
rm -rf $TARGET
EOF_NETC

###############################################################################
## Install NETCDF Fortran library

WORKDIR $WRF_SOURCES

ARG TARGET_URL=https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v4.5.4.tar.gz
ARG TARGET=netcdf-fortran
ARG EXTRA_FLAGS=--disable-shared

RUN <<EOF_NETF
mkdir $TARGET
cd $TARGET

wget -c $TARGET_URL -O $TARGET.tar.gz
mkdir $TARGET-src
tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

mkdir $TARGET-build
cd $TARGET-build
../$TARGET-src/configure --prefix=$WRF_PREFIX $EXTRA_FLAGS
make -j$(nproc)
make install

cd $WRF-SOURCES
rm -rf $TARGET
EOF_NETF


###############################################################################
## Install MPICH

WORKDIR $WRF_SOURCES

ARG TARGET_URL=https://github.com/pmodels/mpich/releases/download/v4.0.2/mpich-4.0.2.tar.gz
ARG TARGET=mpich
ARG EXTRA_FLAGS=--with-device=ch3

RUN <<EOF_MPICH
mkdir $TARGET
cd $TARGET

wget -c $TARGET_URL -O $TARGET.tar.gz
mkdir $TARGET-src
tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

mkdir $TARGET-build
cd $TARGET-build
../$TARGET-src/configure --prefix=$WRF_PREFIX $EXTRA_FLAGS
make -j$(nproc)
make install

cd $WRF-SOURCES
rm -rf $TARGET 
EOF_MPICH

###############################################################################
## general arguments

ARG JASPER_INC=$WRF_PREFIX/include
ARG PNG_INC=$WRF_PREFIX/include
ARG NETCDF=$WRF_PREFIX/

###############################################################################
## Install WRF v4.3.3

WORKDIR $WRF_SOURCES

ARG TARGET_URL=https://github.com/wrf-model/WRF/archive/v4.3.3.tar.gz 
ARG TARGET=WRF
ARG EXTRA_FLAGS=

RUN <<EOF_WRF
mkdir $TARGET
cd $TARGET

wget -c $TARGET_URL -O $TARGET.tar.gz
mkdir $TARGET-src
tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

cd $TARGET-src
printf '34\n1\n' | ./configure $EXTRA_FLAGS
./compile em_real
EOF_WRF

ARG WRF_DIR=$WRF_SOURCES/$TARGET/$TARGET-src

###############################################################################
## Install WPS

WORKDIR $WRF_SOURCES

ARG TARGET_URL=https://github.com/wrf-model/WPS/archive/refs/tags/v4.3.1.tar.gz
ARG TARGET=WPS
ARG EXTRA_FLAGS=

RUN <<EOF_WPS
mkdir $TARGET
cd $TARGET

wget -c $TARGET_URL -O $TARGET.tar.gz
mkdir $TARGET-src
tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1

cd $TARGET-src
printf '3\n' | ./configure $EXTRA_FLAGS
./compile $EXTRA_FLAGS
EOF_WPS

###############################################################################
## Install WPSPLUS 

#WORKDIR $WRF_SOURCES
#
#ARG TARGET_URL=https://github.com/wrf-model/WRF/archive/v4.3.3.tar.gz 
#ARG TARGET=WRFPLUS
#ARG EXTRA_FLAGS=wrfplus
#
#WORKDIR $TARGET
#RUN wget -c $TARGET_URL -O $TARGET.tar.gz && \
#    mkdir $TARGET-src && \
#    tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1
#
#WORKDIR $TARGET-src
#RUN printf '18\n' | ./configure $EXTRA_FLAGS && ./compile $EXTRA_FLAGS
#
#ARG WRFPLUS_DIR=$WRF_PREFIX/$TARGET

###############################################################################
## Install WPSPLUS 4DVAR

#WORKDIR $WRF_SOURCES
#
#ARG TARGET_URL=https://github.com/wrf-model/WRF/archive/v4.3.3.tar.gz 
#ARG TARGET=WRFPLUS_4D
#ARG EXTRA_FLAGS=
#
#WORKDIR $TARGET
#RUN wget -c $TARGET_URL -O $TARGET.tar.gz && \
#    mkdir $TARGET-src && \
#    tar -xf $TARGET.tar.gz -C $TARGET-src --strip-components=1
#
#WORKDIR $TARGET-src
#RUN printf '18\n' | ./configure 4dvar && ./compile all_wrfvar

###############################################################################
## Return to main directory

WORKDIR /