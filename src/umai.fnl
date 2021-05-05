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

(fn make! [rendered]
  (if (core.has? rendered.meta :target)
    (let [content rendered.data
          target rendered.meta.target
          cache (.. (os.getenv "HOME") "/.config/umai/" (fs.basename target))]
      (fs.mkdir (fs.dirname cache))
      (fs.write cache content)
      (fs.link cache target))
    (error "cannot install, no target is specified")))

(fn install! [path]
  (print (.. ":: " path))
  (->> (fs.read path)
       (parse)
       (render)
       (make!)))

(if (not= nil (. arg 1))
  (each [_ a (ipairs arg)]
    (install! a)))
