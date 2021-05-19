(local fs (require :fs))

(local core (require :core))
(fn pretty [...]
  (print (core.inspect ...)))

(local make {})
(local hook {})

(local cache-path (.. (os.getenv "HOME") "/.config/umai/"))
(fs.mkdir cache-path)

(fn cache [path data]
  "save data to umai's cache folder and return its path"
  (let [cache-target (.. cache-path (path:gsub "[~/]" "_"))]
    (fs.write cache-target data)
    cache-target))

; hook

(fn hook.softlink [v data]
  "cache data and symlink it to the destination"
  (fs.link (cache v data) v))

(fn hook.shell [v]
  "not safe, obviously"
  (os.execute v))

; make

(fn make.make [rendered]
  (let [data rendered.data
        meta rendered.meta]
    ;(pretty meta)
    (each [_ m (ipairs meta)]
      (let [f (. hook (. m 1))
            v (. m 2)]
        (if f
          (f v data)
          (print (.. "err: hook '" (. m 1) "' is undefined")))))))

(setmetatable
  make {:__call (fn [_ ...] (make.make ...))})

make
