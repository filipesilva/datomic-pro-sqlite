# https://github.com/docker-library/repo-info/tree/master/repos/clojure/remote
FROM clojure:temurin-21-tools-deps-1.12.0.1530-bookworm-slim

RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# https://docs.datomic.com/setup/pro-setup.html#get-datomic
ARG DATOMIC_VERSION="1.0.7394"
RUN curl https://datomic-pro-downloads.s3.amazonaws.com/${DATOMIC_VERSION}/datomic-pro-${DATOMIC_VERSION}.zip \
    -o datomic-pro.zip \
    && echo "8e3a6334dfc728c1c431dccc537dc88a9d2baf70f29bad5438df9d7c8c7146ae  datomic-pro.zip" | sha256sum datomic-pro.zip \
    && unzip datomic-pro.zip \
    && mv datomic-pro-${DATOMIC_VERSION} /usr/datomic-pro \
    || exit 1

RUN curl -L https://github.com/xerial/sqlite-jdbc/releases/download/3.50.3.0/sqlite-jdbc-3.50.3.0.jar \
    -o sqlite-jdbc-3.50.3.0.jar \
    && echo "a3f53a2aa15ae9425a9e793bbe9c8e5288febeb4b65ef5c1a4e80d4c2045cf08  sqlite-jdbc-3.50.3.0.jar" | sha256sum -c - \
    && mv sqlite-jdbc-3.50.3.0.jar /usr/datomic-pro/lib \
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
