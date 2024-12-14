# Datomic Pro SQLite

Get started with [Datomic Pro](https://www.datomic.com) quickly on a single machine setup that will take you pretty far.

Inspired by how Rails 8 now [uses SQLite for production](https://youtu.be/l56IBad-5aQ).

Links: [GitHub](https://github.com/filipesilva/datomic-pro-sqlite) [DockerHub](https://hub.docker.com/r/filipesilva/datomic-pro-sqlite)


## Quickstart

- run `docker run -p 4334:4334 -v ./storage:/usr/storage --name datomic-pro-sqlite-demo --rm filipesilva/datomic-pro-sqlite:latest`
- wait until it says `Connect using DB URI datomic:sql://app?jdbc:sqlite:<LOCAL/PATH/TO/sqlite.db>`
- connect from your clojure app or from a `clj` REPL:
``` clojure
(add-libs {'com.datomic/peer       {:mvn/version "1.0.7260"}
           'org.xerial/sqlite-jdbc {:mvn/version "3.47.0.0"}})
(require '[datomic.api :as d])

(def db-uri "datomic:sql://app?jdbc:sqlite:./storage/sqlite.db")
(def conn (d/connect db-uri))

(d/transact conn [{:db/ident :foo}])
(d/pull (d/db conn) '[*] :foo)
;; => #:db{:id 17592186045417, :ident :foo}
```

## Usage

Start a new container named `datomic-pro-sqlite-demo` that mounts the local `./storage` folder in the container.
Your SQLite database will be here.
You don't have to make this folder, the container will make it for you.
Delete `./storage` and restart the container if you want to wipe the dabatase. 

```sh
docker run -p 4334:4334 -v ./storage:/usr/storage --name datomic-pro-sqlite-demo --rm filipesilva/datomic-pro-sqlite:latest
```

You should see this output:
```
Creating sqlite database at /usr/storage/sqlite.db
Launching with Java options -server -Xms1g -Xmx1g -XX:+UseG1GC -XX:MaxGCPauseMillis=50
System started
Testing connection to database 'app'...
Testing connection to database 'app'...
Testing connection to database 'app'...
Testing connection to database 'app'...
Created database 'app'
Connect using DB URI datomic:sql://app?jdbc:sqlite:<LOCAL/PATH/TO/sqlite.db>
  e.g. datomic:sql://app?jdbc:sqlite:./storage/sqlite.db if you mounted ./storage
```

The container will automatically create the `app` db.
You can change this by passing in another name in the env var `DATOMIC_DB` when creating the container (e.g. `-e DATOMIC_DB=blog` before the `filipesilva/datomic-pro-sqlite:latest` image name).

Start a new clojure repl with `clj` and use the database.
You will need the SQLite driver dependency in addition to Datomic.

```clojure
(add-libs {'com.datomic/peer       {:mvn/version "1.0.7260"}
           'org.xerial/sqlite-jdbc {:mvn/version "3.47.0.0"}})
(require '[datomic.api :as d])

(def db-uri "datomic:sql://app?jdbc:sqlite:./storage/sqlite.db")
(def conn (d/connect db-uri))

(d/transact conn [{:db/ident :foo}])
(d/pull (d/db conn) '[*] :foo)
;; => #:db{:id 17592186045417, :ident :foo}
```

In tests use the in-memory db instead.

```clojure
(def test-db-uri (str "datomic:mem://test-" (random-uuid)))
(d/create-database test-db-uri)
(def test-conn (d/connect test-db-uri))

(d/pull (d/db test-conn) '[*] :foo)
;; => #:db{:id nil}
```


### Deployment

If you're running your clojure app in a container remember to also mount `./storage` there.
The Datomic peer library needs access to the SQLite db too.

You'll want backups of the SQLite db. You can just backup the `./storage` directory at any time. 

[Litestream](https://litestream.io) is a great automated solution that continuously replicates your db to a s3-compatible bucket, and lets you restore it back easily.
This is what the Rails 8 folks recommend.

Datomic restore and backup also works as usual since all the datomic files are in `/usr/datomic-pro`, you just need to mount the directories you want to use.
This is especially useful if you want to move from SQLite to a different [storage service](https://docs.datomic.com/operation/storage.html).

To restore and then backup the [Datomic MusicBrainz sample database backup](https://github.com/Datomic/mbrainz-sample):
```
# get mbrainz backup
curl https://s3.amazonaws.com/mbrainz/datomic-mbrainz-1968-1973-backup-2017-07-20.tar -o mbrainz.tar
tar -xvf mbrainz.tar

# mount ./mbrainz at /usr/restore, and a new ./backup directory /usr/backup
docker run -p 4334:4334 -v ./storage:/usr/storage -v ./mbrainz-1968-1973:/usr/restore -v ./backup:/usr/backup --name datomic-pro-sqlite-demo --rm filipesilva/datomic-pro-sqlite:latest

# in another console, restore the backup with docker exec
docker exec datomic-pro-sqlite-demo /usr/datomic-pro/bin/datomic restore-db file:///usr/restore/ datomic:sql://mbrainz-1968-1973?jdbc:sqlite:/usr/storage/sqlite.db

# back it up again
docker exec datomic-pro-sqlite-demo /usr/datomic-pro/bin/datomic backup-db datomic:sql://mbrainz-1968-1973?jdbc:sqlite:/usr/storage/sqlite.db file:///usr/backup/

```


## Development

Dev scripts are at `bin` and mostly contain the commands in this README for ease of testing.

Exceptions are:
- `build` to build the image
- `push` to push it to Dockerhub
