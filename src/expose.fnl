(local expose {})

(set expose.data {})

(fn expose.expose [xt]
  (each [k v (pairs xt)]
    (tset expose.data k v)))

(setmetatable expose {:__call (fn [_ ...] (expose.expose ...))})

expose
