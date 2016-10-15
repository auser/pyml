OWNER:=auser
ARGS?=
DARGS?=

include .env

.PHONY: build-all help environment-check release-all

ALL_STACKS:=base \
						volume_container \
						python23 \
						notebook \
						tensorflow \
						opencv \
						torch
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
MACHINES_DIR := ./machines
STACKS_DIR := ./stacks

# build/cuda-base:
	# docker build $(DARGS) --rm --force-rm -t $(OWNER)/cuda-base:latest -f machines/base/Dockerfile-cuda-7.5-cudnn4-devel machines/base

lib= ./$(MACHINES_DIR)
# dockerfile: $(lib)/stages/*.m4
# 	@m4 -I $(MACHINES_DIR)/stages -I $(MACHINES_DIR) $(MACHINES_DIR)/Dockerfile.m4 > Dockerfile.build
# 	@env | j2 --format=env Dockerfile.build > $(MACHINES_DIR)/Dockerfile
# 	@rm Dockerfile.build

test_build: dockerfile
	docker build --rm --force-rm $(MACHINES_DIR)

vb_build:
	cd $(MACHINES_DIR)/host && packer build --only=virtualbox-iso ./template.json

dockerfile/%:
	@echo "Building dockerfile"
	@m4 -I $(MACHINES_DIR)/stages -I $(MACHINES_DIR) $(MACHINES_DIR)/$(notdir $@)/Dockerfile.m4 > $(MACHINES_DIR)/$(notdir $@)/Dockerfile.build
	@env | j2 --format=env $(MACHINES_DIR)/$(notdir $@)/Dockerfile.build > $(MACHINES_DIR)/$(notdir $@)/Dockerfile
	@rm $(MACHINES_DIR)/$(notdir $@)/Dockerfile.build

stacksdockerfile/%:
	@m4 -I $(MACHINES_DIR)/stages -I $(STACKS_DIR) $(STACKS_DIR)/$(notdir $@)/Dockerfile.m4 > $(STACKS_DIR)/$(notdir $@)/Dockerfile.build
	@env | j2 --format=env $(STACKS_DIR)/$(notdir $@)/Dockerfile.build > $(STACKS_DIR)/$(notdir $@)/Dockerfile
	@rm $(STACKS_DIR)/$(notdir $@)/Dockerfile.build

build/%: DARGS?=
stacks/%: DARGS?=

MACHINE_PATH := $(subst build/,,,$@)
GIT_MASTER_HEAD_SHA:=$(shell git rev-parse --short=12 --verify HEAD)

build/%: dockerfile/%
	docker build $(DARGS) --rm --force-rm -t $(OWNER)/$(notdir $@):latest -f ./machines/$(notdir $@)/Dockerfile ./machines/$(notdir $@)

stacks/%: stacksdockerfile/%
	@echo "hi"
	docker-compose $(DARGS) -f $(STACKS_DIR)/$(notdir $@)/docker-compose.yml build

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
