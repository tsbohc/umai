(local core (require :core))
(local fetch (require :fetch))
(local lexis (require :lexis))
(local sandbox (require :sandbox))

(local render {})

(fn inject-single [s]
  "render the leaf-most {expression} in string 's'"
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
  (if (= "Lua 5.1" _VERSION)
    (let [f (loadstring (if (not (s:find "return ")) (.. "return " s) s))]
      (setfenv f sandbox)
      (f))
    (let [f (load (if (not (s:find "return ")) (.. "return " s) s))]
      (core.setfenv f sandbox)
      (f))))

(fn render.single [s]
  "render a single fragment in string 's'"
  (if (s:find lexis.statement-re)
    (let [cs (s:sub (+ (lexis.s-l:len) 1) (* -1 (+ (lexis.s-r:len) 1)))]
      (if (s:find lexis.expression-re)
        (inject cs)
        (evaluate cs)))
    s))

(fn render.render [xs]
  "render a sequence of fragments 'xs' into data and meta"
  (let [data []
        meta {}]
    (each [_ s (ipairs xs)]
      (let [(d m) (render.single s)]
        (table.insert data d)
        (table.insert meta m)))
    {:data (table.concat data) :meta meta}))

(setmetatable
  render {:__call (fn [_ ...] (render.render ...))})

render
