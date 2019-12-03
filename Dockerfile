# Run these commands to get started:
#   docker-compose build
#   docker-compose up -d
#   docker exec -it r2playground /bin/bash

FROM ubuntu:bionic

ENV DEBIAN_FRONTEND noninteractive

# == Install the basics ====================================================
RUN apt-get clean
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -y \
    git \
    vim \
    wget \ 
    gcc \
    cmake \
    flex \ 
    bison \ 
    pkg-config \
    build-essential \
    binutils \
    python \
    python-pip 

# == Download version of cmake for r2ghidra-dec ==============================
ARG VERSION=3.12
ARG BUILD=0
RUN apt-get purge cmake -y 
RUN mkdir ~/temp
RUN cd ~/temp
RUN wget https://cmake.org/files/v${VERSION}/cmake-${VERSION}.${BUILD}.tar.gz
RUN tar -xzvf cmake-${VERSION}.${BUILD}.tar.gz
RUN cd cmake-${VERSION}.${BUILD}/ \
    && ls \
    && ./bootstrap \ 
    && make -j4 \
    && make install \ 
    && cd .. \
    && rm -rf cmake-3.12.0 \ 
    && rm cmake-3.12.0.tar.gz \
    && rm -rf ./temp !

# == Download & setup r2 =====================================================
WORKDIR /opt
RUN git clone https://github.com/radareorg/radare2.git 
RUN cd radare2/sys && ./install.sh

# == Setup r2pm ==============================================================
RUN r2pm init 
RUN r2pm update

# == Download r2ghidra-dec ===================================================
RUN r2pm -i r2ghidra-dec

# == Destination once it's started ===========================================
WORKDIR /r2Playground