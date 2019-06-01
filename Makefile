default: app

all: package

clean: clean-docker
	rm -rf build
	rm -rf app/build
	rm -rf aws-lambda-cpp/build
	rm -rf dist

clean-docker:
	rm -rf from_docker

build-in-docker:
	docker rm -f hello-aws-lambda-cpp-ci || true
	docker build -t hello-aws-lambda-cpp-ci .
	docker create --name hello-aws-lambda-cpp-ci hello-aws-lambda-cpp-ci

	mkdir -p ./from_docker
	docker cp hello-aws-lambda-cpp-ci:/src/app/build/hello.zip ./from_docker/hello.zip

	echo Artifacts extracted to ./from_docker/

deps:
    # Workaround for https://github.com/awslabs/aws-lambda-cpp/issues/45
	ldd /bin/bash | awk '{print $$(NF-1)}' | grep ld-linux | awk -F/ '{print $$3}' > /tmp/loader_path
	cat /tmp/loader_path
	sed -i 's/PKG_LD=\"\"/PKG_LD=$(shell cat \/tmp\/loader_path)/' aws-lambda-cpp/packaging/packager

	mkdir -p out && \
	cd aws-lambda-cpp && \
	mkdir -p build && \
	cd build && \
	cmake .. \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DBUILD_SHARED_LIBS=OFF \
	  -DCMAKE_INSTALL_PREFIX=${CURDIR}/dist && \
	$(MAKE) && \
	$(MAKE) install

	sed -i 's/PKG_LD=$(shell cat \/tmp\/loader_path)/PKG_LD=\"\"/' aws-lambda-cpp/packaging/packager

app: deps
	mkdir -p out/bin && \
	cd app && \
	mkdir -p build && \
	cd build && \
	cmake .. \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DBUILD_SHARED_LIBS=OFF \
	  -DCMAKE_INSTALL_PREFIX=${CURDIR}/dist && \
	$(MAKE)

package: deps app
	cd app/build && \
	$(MAKE) aws-lambda-package-hello && \
	cp hello.zip ../../dist