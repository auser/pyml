OWNER:=auser
ARGS?=
DARGS?=

include .env

.PHONY: build-all help environment-check release-all

ALL_STACKS:=base \
						volume_container
	# notebook-opencv
# ALL_STACKS:=python23 \
	# spark \
	# opencv \
	# tensorflow \
	# torch \
	notebook-opencv
	# tensorflow \
	# torch \

ALL_IMAGES:=$(ALL_STACKS)
MACHINES_DIR := machines

# build/cuda-base:
	# docker build $(DARGS) --rm --force-rm -t $(OWNER)/cuda-base:latest -f machines/base/Dockerfile-cuda-7.5-cudnn4-devel machines/base

lib= ./$(MACHINES_DIR)
# dockerfile: $(lib)/stages/*.m4
# 	@m4 -I $(lib)/stages -I $(lib) $(lib)/Dockerfile.m4 > Dockerfile.build
# 	@env | j2 --format=env Dockerfile.build > $(lib)/Dockerfile
# 	@rm Dockerfile.build

test_build: dockerfile
	docker build --rm --force-rm $(lib)

vb_build:
	cd $(MACHINES_DIR)/host && packer build --only=virtualbox-iso ./template.json

dockerfile/%:
	@m4 -I $(lib)/stages -I $(lib) $(lib)/$(notdir $@)/Dockerfile.m4 > $(lib)/$(notdir $@)/Dockerfile.build
	@env | j2 --format=env $(lib)/$(notdir $@)/Dockerfile.build > $(lib)/$(notdir $@)/Dockerfile
	@rm $(lib)/$(notdir $@)/Dockerfile.build

build/%: DARGS?=

MACHINE_PATH := $(subst build/,,,$@)
GIT_MASTER_HEAD_SHA:=$(shell git rev-parse --short=12 --verify HEAD)

build-all: $(patsubst %,build/%, $(ALL_IMAGES))

build/%: dockerfile/%
	docker build $(DARGS) --rm --force-rm -t $(OWNER)/$(notdir $@):latest -f ./machines/$(notdir $@)/Dockerfile ./machines/$(notdir $@)

up:
	docker-compose -p pydock up -d

down:
	docker-compose -p pydock stop

backup:
	docker run --volumes-from pydock_core_1 -v $(CURDIR):/backup ubuntu bash -c "cd /home/compute/notebooks && tar cvfz /backup/backup.tar.gz ."

restore:
	docker run --volumes-from pydock_core_1 -v $(CURDIR):/backup ubuntu bash -c "cd /home/compute/notebooks && tar xfz /backup/backup.tar.gz"

script:
	go build -o scripts/boot scripts/boot.go

clean:
	rm -rf output-*
	rm -rf *.box
