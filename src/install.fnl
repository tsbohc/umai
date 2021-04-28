(local install {})

(require-macros :macros)
(local core (require :core))
(local fs (require :fs))

(local cache (.. (os.getenv :HOME) "/.config/umai/"))

(fn install.install [rendered]
  (when (not (fs.exists? cache))
    (fs.mkdir cache))
  (if (core.has? rendered.meta :target)
    (let [content rendered.data
          path (.. cache (fs.basename rendered.meta.target))]
      (fs.write path content)
      (fs.link path rendered.meta.target))
    (error "cannot install, no target is specified")))

(setmetatable install {:__call (fn [_ ...] (install.install ...))})

install
