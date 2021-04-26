(local fs {})

(fn fs.slurp [path]
  "return file contents as a string, accepts 'path'"
  (with-open
    [file (assert (io.open path "r"))]
    (let [s (file:read "*a")]
      s)))


fs
