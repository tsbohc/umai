(require-macros :macros)
(local core (require :core))
(local varset (require :varset))
(local expose (require :expose))

(local get {})

(fn fe [xt path]
  (. xt path))

; (fn get.from-lush [s])

;(fn get.from-env [s]
;  (os.getenv (.. "BLOSSOM_" s)))

(fn get.from-exp [s]
  (fe expose.data s))


(fn get.from-var [s]
  ; TODO: put patterns into lexis
  (let [root (s:match "(%w+)%.")
        path (s:match "%.([%w.]+)")]
    (when (not= nil root)
      (if (has? (varset.list) root)
        (fe (varset root) path)
        (error (.. "varset '" root "' doesn't exist"))))))


(fn get.get [s]
  (let [v (or (get.from-exp s) (get.from-var s))]
    (if (nil? v)
      (error (.. "value of token '" s "' could not be found."))
      v)))


(setmetatable get {:__call (fn [_ ...] (get.get ...))})
get
