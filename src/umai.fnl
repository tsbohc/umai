(local fs (require :fs))
(local core (require :core))
(local parse (require :parse))
(local render (require :render))
(local fetch (require :fetch))
(local expose (require :expose))

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
       (make!)
       ))

(fn nvim-rtp []
  (with-open
    [file (assert (io.popen "nvim --headless -c 'set runtimepath' -c 'q'" "r"))]
    (let [out (file:read "*a")]
      (pick-values 1 (out:gsub "\n" "")))))

(fn get-lush-rtp []
  (var r false)
  (let [rtp (.."," (nvim-rtp) ",")]
    (each [e (rtp:gmatch "([^,]+)")]
      (if (e:find "lush.nvim$")
        (let [e (e:gsub "~" (os.getenv "HOME"))
              e (.. e "/lua/?.lua")]
          (set r e)))))
  r)

(fn get-theme-rtp []
  (var r false)
  (let [rtp (.."," (nvim-rtp) ",")]
    (each [e (rtp:gmatch "([^,]+)")]
      (if (e:find "limestone")
        (let [e (e:gsub "~" (os.getenv "HOME"))
              e (.. e "/lua/lush_theme/?.lua")]
          (set r e)))))
  r)

(set package.path (.. package.path ";" (get-lush-rtp)))
(set package.path (.. package.path ";" (get-theme-rtp)))
(local limestone (require :limestone))

(fn get-colors-from-lush []
  (let [r {}]
    (each [k v (pairs limestone.X.lush)]
      (tset r k (v.hex:gsub "#" "")))
    r))

(expose.set :kohi (get-colors-from-lush))

(if (not= nil (. arg 1))
  (each [_ a (ipairs arg)]
    (install! a)))

;(macro ?- [e r]
;  `(do
;     (print "")
;     (print (.. "= " ,e " " ,(tostring r)))
;     (if (= ,e ,r)
;       (print "pass")
;       (print (.. "expected '" (core.inspect ,e)
;                  "', received '" (core.inspect ,r) "'")))))
;
;
;(?- 20 (render.single "{% 3 * 7 - 1 %}"))
;(?- "kohi" (render.single "{% {colo} %}"))
;(?- "colo: kohi" (render.single "{% 'colo: ' .. '{colo}' %}"))
