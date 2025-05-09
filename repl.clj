(add-libs {'com.datomic/peer       {:mvn/version "1.0.7364"}
           'org.xerial/sqlite-jdbc {:mvn/version "3.47.0.0"}})
(require '[datomic.api :as d])

(def db-uri "datomic:sql://app?jdbc:sqlite:./storage/sqlite.db")
(def conn (d/connect db-uri))

(d/transact conn [{:db/ident :foo}])
(d/pull (d/db conn) '[*] :foo)
;; => #:db{:id 17592186045417, :ident :foo}

(def test-db-uri (str "datomic:mem://test-" (random-uuid)))
(d/create-database test-db-uri)
(def test-conn (d/connect test-db-uri))
(d/pull (d/db test-conn) '[*] :foo)
;; => #:db{:id nil}
