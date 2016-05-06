OWNER=auser

.PHONY: build-all help environment-check release-all

ALL_STACKS:=cuda \
	python23 \
	spark \
	opencv \
	tensorflow \
	torch \
	notebook
	# tensorflow \
	# torch \

ALL_IMAGES:=$(ALL_STACKS)

MACHINES_DIR := machines

build/%: DARGS?=

MACHINE_PATH := $(subst build/,,,$@)

GIT_MASTER_HEAD_SHA:=$(shell git rev-parse --short=12 --verify HEAD)


build-all: $(patsubst %,build/%, $(ALL_IMAGES))

build/%:
	docker build $(DARGS) --rm --force-rm -t $(OWNER)/$(notdir $@):latest ./machines/$(notdir $@)

dev/%: ARGS?=
dev/%: DARGS?=
dev/%: PORT?=8888
dev/%: HOST_PORT?=$(PORT)
dev/%:
	docker run -it --rm -p $(PORT):$(HOST_PORT) $(DARGS) $(OWNER)/$(notdir $@) $(ARGS)

push/%:
	docker push $(OWNER)/$(notdir $@):latest
	docker push $(OWNER)/$(notdir $@):$(GIT_MASTER_HEAD_SHA)

push-all: $(patsubst %,push/%, $(ALL_IMAGES))

tag/%:
# always tag the latest build with the git sha
	docker tag -f $(OWNER)/$(notdir $@):latest $(OWNER)/$(notdir $@):$(GIT_MASTER_HEAD_SHA)

tag-all: $(patsubst %,tag/%, $(ALL_IMAGES))


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
	docker-cleanup
