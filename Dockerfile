FROM ubuntu:latest
MAINTAINER Fedor Baart <fedor.baart@deltares.nl>
# skip any questions
ENV DEBIAN_FRONTEND noninteractive
# clean up cache
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get clean && apt-get update
# install packages
RUN apt-get install -y python3 libhdf5-serial-dev \
    nco wget subversion python3-netcdf4 build-essential \
    gfortran libnetcdff-dev flex bison libexpat1-dev \
    environment-modules openmpi-bin libopenmpi-dev \
    cython3 python3-pip python3-pytest

RUN pip3 install mako bokeh

RUN mkdir -p /src/delft3d
RUN mkdir -p /src/nefis-python
COPY build-entrypoint.sh /root
# volume points for source code
VOLUME /src/delft3d
VOLUME /src/nefis-python
WORKDIR /src/delft3d
CMD /root/build-entrypoint.sh
