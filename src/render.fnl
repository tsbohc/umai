(local core (require :core))
(local fetch (require :fetch))
(local lexis (require :lexis))
(local sandbox (require :sandbox))

(local render {})

(fn inject-single [s]
  "render a leaf-most {expression} in string 's'"
  (let [key (s:match lexis.expression-re)
        val (fetch key)
        l (lexis.e-l:escape) r (lexis.e-r:escape)]
    (s:gsub (.. l key r) val)))

(fn inject [s]
  "recursively render {expresson}s in string 's'"
  (if (s:find lexis.expression-re)
    (inject (inject-single s))
    s))

(fn evaluate [s]
  "evaluate arbitrary lua string 's' in a sandbox"
  (let [f (load (if (not (s:find "return ")) (.. "return " s) s))]
    (core.setfenv f sandbox)
    (f)))

(fn render.single [s]
  "render a single fragment in string 's'"
  (if (s:find lexis.statement-re)
    (let [cs (s:sub (+ (lexis.s-l:len) 1) (* -1 (+ (lexis.s-r:len) 1)))]
      (-> cs
          (inject)
          (evaluate)))
    s))

(fn render.render [xs]
  "render a sequence of fragments 'xs' into data and meta"
  (let [data []
        meta {}]
    (each [_ s (ipairs xs)]
      (let [(d m) (render.single s)]
        (table.insert data d)
        (core.merge! meta m)))
    {:data (table.concat data) :meta meta}))

(setmetatable
  render {:__call (fn [_ ...] (render.render ...))})

render
