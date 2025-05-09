# https://github.com/docker-library/repo-info/tree/master/repos/clojure/remote
FROM clojure:temurin-21-tools-deps-1.12.0.1530-bookworm-slim

RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# https://docs.datomic.com/setup/pro-setup.html#get-datomic
ARG DATOMIC_VERSION="1.0.7364"
RUN curl https://datomic-pro-downloads.s3.amazonaws.com/${DATOMIC_VERSION}/datomic-pro-${DATOMIC_VERSION}.zip \
    -o datomic-pro.zip \
    && echo "76d35de6d2807a88a865a13fa8382aa9eb4106582e7fbd79cdd3c26d1f64bd73  datomic-pro.zip" | sha256sum -c - \
    && unzip datomic-pro.zip \
    && mv datomic-pro-${DATOMIC_VERSION} /usr/datomic-pro \
    || exit 1

RUN curl -L https://github.com/xerial/sqlite-jdbc/releases/download/3.47.0.0/sqlite-jdbc-3.47.0.0.jar \
    -o sqlite-jdbc-3.47.0.0.jar \
    && echo "93d47c006377c476f8f7b45d00d20606b77d5951423f346ef56b5b081361c2d3  sqlite-jdbc-3.47.0.0.jar" | sha256sum -c - \
    && mv sqlite-jdbc-3.47.0.0.jar /usr/datomic-pro/lib \
    || exit 1

FROM clojure:temurin-21-tools-deps-1.12.0.1530-bookworm-slim

RUN apt-get update && apt-get install -y sqlite3 && rm -rf /var/lib/apt/lists/*

COPY --from=0 /usr/datomic-pro /usr/datomic-pro
COPY transactor.properties /usr/datomic-pro/config/
COPY create-db.bsh /usr/create-db.bsh
HEALTHCHECK CMD /usr/bin/env sh -c '[ -f "/usr/datomic-pro/db_ready" ]' || exit 1
COPY start.sh /usr/start.sh
RUN chmod +x /usr/start.sh

CMD ["/usr/start.sh"]
