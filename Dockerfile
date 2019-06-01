FROM debian:stretch

RUN apt-get update && apt-get install -y gcc g++ make cmake libcurl4-openssl-dev zip

ADD . /src
RUN mkdir /out

WORKDIR /src/aws-lambda-cpp

# Workaround for https://github.com/awslabs/aws-lambda-cpp/issues/45
RUN ldd /bin/bash | awk '{print $(NF-1)}' | grep ld-linux | awk -F/ '{print $3}' > /tmp/loader_path
RUN sed -i 's/PKG_LD=""/PKG_LD=$(cat \/tmp\/loader_path)/' packaging/packager

RUN mkdir build && cd build && cmake .. -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_INSTALL_PREFIX=/out \
    && make && make install

WORKDIR /src/app

RUN mkdir build &

WORKDIR /src/app/build

RUN cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=/out \
    && make

RUN make aws-lambda-package-hello
