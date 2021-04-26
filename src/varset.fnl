(require-macros :macros)
(local core (require :core))
(local fs (require :fs))

(local varset {})

; TODO: refactor

(memoize _list []
  "retrieve varsets list"
  (with-open
    [file (assert (io.popen "find varsets -type f" "r"))]
    (let [xs []]
      (each [line (file:lines)]
        (table.insert xs (pick-values 1 (line:gsub "varsets/" ""))))
      xs)))


(memoize _get [name]
  "return a varset table by [name]"
  (with-open
    [file (assert (io.open (.. "varsets/" name) "r"))]
    (let [comment-re "%s*!"
          keyval-re  "(%w+):%s*(%w+)"
          xt {}]
      (each [line (file:lines)]
        (when-not (or (line:match comment-re) (= line ""))
          (let [(key val) (line:match keyval-re)]
            (tset xt key val))))
      xt)))


(tset varset :list _list)
(tset varset :get _get)

(setmetatable varset {:__call (fn [_ ...] (varset.get ...))})

varset
