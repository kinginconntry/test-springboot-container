.PHONY: all

NAME=test_springboot_container
BASE_DIR=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
RELEASE=${BASE_DIR}/release
TARGET_BIN=${RELEASE}

DATE=$(shell date +"%Y%m%d%H%M%S")

FLAGS:= -X 'main.gitversion=$(shell git rev-parse --short HEAD)'
FLAGS+= -X 'main.gitbranch=$(shell git branch | grep "\*" | grep " .*" -o | sed "s/\ //g")'
FLAGS+= -X 'main.buildstamp=${DATE}'
FLAGS+= -X 'main.goversion=$(shell go version)'
FLAGS+= -X 'main.sysuname=$(shell uname -mns)'

GOBUILD= GOOS=linux GOARCH=amd64 go build

define compile_and_pack
    @rm -rf ${RELEASE}
	@mkdir -p ${TARGET_BIN}
	$(GOBUILD) -o ${TARGET_BIN}/$(NAME) -ldflags "${FLAGS}" ${BASE_DIR}/main.go
endef

all:
	$(call compile_and_pack)

clean:
	@rm -rf ${RELEASE}

lint:
	golangci-lint run