(local args (require :args))
(local fs (require :fs))
(local parse (require :parse))
(local render (require :render))
(local make (require :make))

(local core (require :core))
(local expose (require :expose))
(local fetch (require :fetch))

; FIXME: LUSH
; i think the best we can do is to launch a subshell, run lua, retrieve values, and write them to a varset

(fn pretty [...]
  (print (core.inspect ...)))

(fn install! [path]
  (->> (fs.read path)
       (parse)
       (render)
       (make)))

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

(expose.set :limestone (get-colors-from-lush))

(args.parse [...])
;(pretty args)

(each [_ v (ipairs args.files)]
  (install! v))



; ---

;(if (not= nil (. arg 1))
;  (each [_ a (ipairs arg)]
;    (install! a)))

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
