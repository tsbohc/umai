(local core (require :core))
(local fetch (require :fetch))
(local lexis (require :lexis))
(local sandbox (require :sandbox))
(local render {})

; TODO: warn instead of erroring when {}'s couldn't be rendered

(fn inject? [s]
  "check if string 's' contains a {token}"
  (if (s:find lexis.token-re) true false))


(fn inject-single [s]
  "render a leaf-most {token} in string 's'"
  (let [key (s:match lexis.token-re)
        val (fetch key)]
    (pick-values 1 (s:gsub (lexis.token-esc key) val))))


(fn render.inject [s]
  "recursively render {tokens} in string 's'"
  ; TODO: check for max recursion depth?
  (if (inject? s)
    (render.inject (inject-single s))
    s))


(fn render.evaluate [s]
  "evaluate arbitrary lua code in a sandbox"
  (let [f (load (if (not (s:find "return ")) (.. "return " s) s))]
    (core.setfenv f sandbox)
    (f)))


(fn render-single [s]
  "render single fragment"
  (let [hs (.. (s:sub 1 3) (s:sub -3))
        cs (s:sub 4 -4)]
    (match hs
      lexis.statement
      (if (cs:find lexis.expression-re)
        (render.inject cs)
        (render.evaluate cs))
      _ s)
    ))


(fn render.render [xs]
  "render fragment into data and meta"
  (let [data []
        meta {}]
    (each [_ s (ipairs xs)]
      (let [(d m) (render-single s)]
        (table.insert data d)
        (core.merge! meta m)))
    {:data (table.concat data) :meta meta}))


(setmetatable render {:__call (fn [_ ...] (render.render ...))})
render
