(local args
  {:varsets ""
   :vars {}
   :files []})

(local usage "umai - .files management and templating

usage:
  umai [--varsets <path>] [-key val ...] - <template> ...")

(fn args.parse [xs]
  (when
    (or (= "--help" (. xs 1)) (= "-h" (. xs 1)))
    (print usage)
    (os.exit))
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
