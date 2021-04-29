(local fs (require :fs))
(local core (require :core))
(local parse (require :parse))
(local render (require :render))
(local fetch (require :fetch))

; TODO:
; custom file ext? like .umai. what about ft?
; and .garden/etc/umai/root <- "exposed" varset

; write tests

; FIXME: LUSH

(fn pretty [...]
  (print (core.inspect ...)))


(local cache (.. (os.getenv "HOME") "/.config/umai/"))
(when (not (fs.exists? cache))
    (fs.mkdir cache))


(fn templates []
  (with-open
    [file (assert (io.popen (.. "find " (fetch.from-env "ENV") " -name '*.umai' -type f") "r"))]
    (let [xt []]
      (each [line (file:lines)]
        (table.insert xt line))
      xt)))


(fn make! [rendered]
  (if (core.has? rendered.meta :target)
    (let [content rendered.data
          path (.. cache (fs.basename rendered.meta.target))]
      ; TODO: create path to symlinked folder if doesn't exist?
      (fs.write path content)
      (fs.link path rendered.meta.target))
    (error "cannot install, no target is specified")))


(fn install [path]
  (print (.. "installing: " path))
  (->> (fs.realpath path)
       (fs.read)
       (parse)
       (render)
       (make!)))


(fn install-all []
  (core.map install (templates)))


(if (not= nil (. arg 1))
  (each [_ a (ipairs arg)]
    (install a))
  (install-all))
