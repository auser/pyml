OWNER=auser

ALL_MACHINES:=opencv
ALL_IMGAES:=$(ALL_MACHINES)

build/%: DARGS?=

build/%:
	echo "$: $@"
	docker build $(DARGS) --rm --force-rm -t $(OWNER)/$(notdir $@):latest ./machines/$(notdir $@)

dev/%: ARGS?=
dev/%: DARGS?=
dev/%: PORT?=8888
dev/%:
	docker run -it --rm -p $(PORT):8888 $(DARGS) $(OWNER)/$(notdir $@) $(ARGS)

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
