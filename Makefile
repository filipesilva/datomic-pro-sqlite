build:
	docker build --tag dazld/datomic-pro-sqlite:latest image/

start:
	docker run -p 4334:4334 -v ./storage:/usr/storage --name datomic-pro-sqlite-demo --rm dazld/datomic-pro-sqlite:latest

restore-mbrainz:
	docker exec datomic-pro-sqlite-demo /usr/datomic-pro/bin/datomic restore-db file:///usr/restore/ datomic:sql://mbrainz-1968-1973?jdbc:sqlite:/usr/storage/sqlite.db

restore-mbrainz-start:
	@if [ ! -d "mbrainz-1968-1973" ]; then \
        wget https://s3.amazonaws.com/mbrainz/datomic-mbrainz-1968-1973-backup-2017-07-20.tar -O mbrainz.tar; \
        tar -xvf mbrainz.tar; \
    fi

	docker run -p 4334:4334 -v ./storage:/usr/storage -v ./mbrainz-1968-1973:/usr/restore -v ./backup:/usr/backup --name datomic-pro-sqlite-demo --rm dazld/datomic-pro-sqlite:latest
