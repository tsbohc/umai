(local core (require :core))
(local fs (require :fs))
(local expose (require :expose))
(local args (require :args))

(local fetch {})

;(fn fetch.from-env [s]
;  (os.getenv (.. "UMAI_" s)))

(fn fetch.from-arg [s]
  (. args.vars s))

(fn _varset-list []
  "retrieve varsets list"
  (let [path args.varsets]
    (when path
      (with-open
        [file (assert (io.popen (.. "find " path " -type f") "r"))]
        (let [xs []]
          (each [line (file:lines)]
            (table.insert xs (pick-values 1 (line:gsub (.. path "/") ""))))
          xs)))))

(local varset-list
  (core.memoize _varset-list))

(fn _varset-load [name]
  "return a varset table by name"
  (let [path args.varsets
        path (if (= "/" (path:sub -1)) (path:sub 1 -1) path)]
    (when path
      (with-open
        [file (assert (io.open (.. path "/" name) "r"))]
        (let [comment-re "%s*!"
              keyval-re  "(%w+):%s*(%w+)"
              xt {}]
          (each [line (file:lines)]
            (when (not (or (line:match comment-re) (= line "")))
              (let [(key val) (line:match keyval-re)]
                (tset xt key val))))
          xt)))))

(local varset-load
  (core.memoize _varset-load))

(fn fetch.from-expose [s]
  (core.get-dp expose.state s))

(fn fetch.from-varset [s]
  (let [name (s:match "(%w+)%.")
        path (s:match "%.([%w.]+)")]
    (when (not= nil name)
      (core.get-dp (varset-load name) path))))

(fn fetch.fetch [s]
  (let [v (or (fetch.from-arg s) (fetch.from-expose s) (fetch.from-varset s))]
    (if (core.nil? v)
      (error (.. "value of token '" s "' could not be found."))
      v)))

(setmetatable
  fetch {:__call (fn [_ ...] (fetch.fetch ...))})

fetch
