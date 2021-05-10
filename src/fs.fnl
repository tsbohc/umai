(local fs {})

(fn fs.read [path]
  (with-open [file (assert (io.open path "r"))]
    (file:read "*a")))

(fn fs.write [path content]
  (with-open [file (assert (io.open path "w"))]
    (file:write content)))

(fn fs.copy [source target]
  (let [content (fs.read source)]
    (fs.write target content)))

(fn fs.move [source target]
  (os.rename source target))

(fn fs.remove [path]
  (os.remove path))

(fn fs.exists? [path]
  (fs.move path path))

(fn fs.mkdir [path]
  (os.execute (.. "mkdir -p " path)))

(fn fs.link [source target]
  (os.execute (.. "ln -sf " source " " target)))

(fn fs.basename [path]
  (path:match ".*[/\\](.-)$"))

(fn fs.dirname [path]
  (path:match "(.*[/\\])"))

(fn fs.realpath [path]
  (with-open
    [file (assert (io.popen (.. "realpath " path) "r"))]
    (let [out (file:read "*a")]
      (pick-values 1 (out:gsub "\n" "")))))

fs
