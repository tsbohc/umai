(local args
  {:varsets ""
   :vars {}
   :files []})

; NB: we only parse args once, then args.parse is removed

(fn args.parse [xs]
  (var key "")
  (var files? false)
  (each [_ val (ipairs xs)]
    (if (not files?)
      (if
        (= key "--varsets")
        (tset args :varsets val)
        (key:find "%-%S+")
        (tset args.vars (key:sub 2) val)
        (= key "-")
        (do
          (set files? true)
          (table.insert args.files val)))
      (table.insert args.files val))
    (set key val))
  (tset args :parse nil))

args
