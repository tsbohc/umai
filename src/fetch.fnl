(local core (require :core))
(local fs (require :fs))

(local fetch {})

(fn fetch.from-env [s]
  (os.getenv (.. "UMAI_" s)))


(fn _varset-list []
  "retrieve varsets list"
  (let [path (fetch.from-env "VARSETS_DIR")]
    (with-open
      [file (assert (io.popen (.. "find " path " -type f") "r"))]
      (let [xs []]
        (each [line (file:lines)]
          (table.insert xs (pick-values 1 (line:gsub (.. path "/") ""))))
        xs))))


(fn _varset-load [name]
  "return a varset table by [name]"
  (let [path (fetch.from-env "VARSETS_DIR")]
    (with-open
      [file (assert (io.open (.. path "/" name) "r"))]
      (let [comment-re "%s*!"
            keyval-re  "(%w+):%s*(%w+)"
            xt {}]
        (each [line (file:lines)]
          (when (not (or (line:match comment-re) (= line "")))
            (let [(key val) (line:match keyval-re)]
              (tset xt key val))))
        xt))))


(local varset-list (core.memoize _varset-list))
(local varset-load (core.memoize _varset-load))


(fn fetch.from-var [s]
  (let [name (s:match "(%w+)%.")
        path (s:match "%.([%w.]+)")]
    (when (not= nil name)
      (if (core.has? (varset-list) name)
        (core.get-dp (varset-load name) path)
        (error (.. "varset '" name "' doesn't exist"))))))


(fn fetch.fetch [s]
  (let [v (or (fetch.from-env s) (fetch.from-var s))]
    (if (core.nil? v)
      (error (.. "value of token '" s "' could not be found."))
      v)))


(setmetatable fetch {:__call (fn [_ ...] (fetch.fetch ...))})
fetch
