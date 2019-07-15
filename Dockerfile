FROM amazonlinux:2018.03


RUN yum install gcc gcc-c++ make cmake3

ADD . /src

RUN mkdir /out

RUN ldd /bin/bash | tail -n1 | cut -d$'\t' -f2 | cut -d' ' -f1 > /tmp/loader_path

WORKDIR /src/aws-lambda-cpp

RUN mkdir build && cd build && cmake .. -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_INSTALL_PREFIX=~/out \
    && make && make install

WORKDIR /src/app

RUN mkdir build && cd build && cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=~/out \
    && make && make aws-lambda-package-hello
