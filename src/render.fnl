(local core (require :core))
(local get (require :get))
(local lexis (require :lexis))
(local tokens (require :tokens))
(local render {})

(fn strip [s]
  ; TODO: strip whitespace
  "remove handles from string"
  (s:sub 4 -4))


(fn render.inject [s]
  ; TODO: transfer this call to (get "value")
  (tokens.compile s))


(local sandbox {})

(fn sandbox.target [s]
  (values "" {:target s}))

(fn sandbox.get [s]
  (get s))


(fn render.eval [s]
  (let [f (load (if (not (s:find "return ")) (.. "return " s) s))]
    (core.setfenv f sandbox)
    (f)))


(fn compile [s]
  (let [hs (.. (s:sub 1 3) (s:sub -3))
        cs (strip s)]
    (match hs
      lexis.statement
      (if (cs:find lexis.expression-re)
        (render.inject cs)
        (render.eval cs))
      _ s)
    ))


(fn render.render [xs]
  (let [data []
        meta {}]
    (each [_ s (ipairs xs)]
      (let [(d m) (compile s)]
        (table.insert data d)
        (core.merge! meta m)))
    {:data (table.concat data) :meta meta}))

(setmetatable render {:__call (fn [_ ...] (render.render ...))})

render
