(require-macros :macros)
(local core (require :core))
(local get (require :get))

(local petals {})

(memoize _petals []
  (with-open
    [file (assert (io.popen (.. "find " (get.from-env :ENV) " -name '*.petal' -type f") "r"))]
    (let [xt []]
      (each [line (file:lines)]
        (table.insert xt line))
      xt)))

(tset petals :petals _petals)

(setmetatable petals {:__call (fn [_ ...] (petals.petals ...))})

petals
