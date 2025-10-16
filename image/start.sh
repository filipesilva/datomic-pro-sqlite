#!/usr/bin/env sh
set -e

# Create sqlite db if it doesn't exist
if [ ! -f /usr/storage/sqlite.db ]; then
  echo "Creating sqlite database at /usr/storage/sqlite.db"
  sqlite3 /usr/storage/sqlite.db "
-- same as Rails 8.0
PRAGMA foreign_keys = ON;
PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;
PRAGMA mmap_size = 134217728; -- 128 megabytes
PRAGMA journal_size_limit = 67108864; -- 64 megabytes
PRAGMA cache_size = 2000;

-- datomic schema
CREATE TABLE IF NOT EXISTS datomic_kvs (
    id TEXT NOT NULL,
    rev INTEGER,
    map TEXT,
    val BYTEA,
    CONSTRAINT pk_id PRIMARY KEY (id)
);
" > /dev/null
fi

# Run db creation script in background
/usr/datomic-pro/bin/shell /usr/create-db.bsh &

# Run datomic transactor
exec /usr/datomic-pro/bin/transactor /usr/datomic-pro/config/transactor.properties
