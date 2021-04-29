(require-macros :macros)

(local core  (require :core))
(local tokens (require :tokens))
(local fs (require :fs))
(local lexis (require :lexis))
(local expose (require :expose))
(local parse (require :parse))
(local render (require :render))
(local install (require :install))
(local petals (require :petals))

;(tset package :path (.. package.path ";/home/sean/.local/share/nvim/site/pack/packer/start/lush.nvim/lua/?.lua"))

;(local lush (require :lush))

; TODO:
; custom file ext? like .petal? what about ft?
; check for mismatched brackets? count both {} and compare

;(tset package :path (.. package.path ";/home/sean/.local/share/nvim/site/pack/packer/start/kohi/lua/lush_theme/?.lua"))

(expose {:ENV "/home/sean/.garden/etc"})

(local se {})

(set se.ENV "/home/sean/.garden/etc")
(set se.colo "kohi")
;(set se.lush (require :kohi_umai))

(expose se)

(fn make [path]
  (print (.. "installing: " path))
  (->> path
       (fs.read)
       (parse)
       (render)
       (install)))

(core.map make (petals))


;(local parsed (parse temp))
;
;(print "")
;
;(local (rendered metadata) (render parsed))
;(pretty rendered)
;(print "")
;(pretty metadata)



;
;(fn p [s]
;  (let [xs []
;        (s-x s-y) (s:find statement-re)
;        (e-x e-y) (s:find expression-re)]
;    (print (s:sub s-x s-y))
;    (print (s:sub e-x e-y))
;    (if (< s-x e-x)
;      (do
;        (table.insert xs (s:sub 1 (- s-x 1)))
;        (table.insert xs (s:sub s-x s-y)))
;      (do
;        (table.insert xs (s:sub 1 (- e-x 1)))
;        (table.insert xs (s:sub e-x e-y))))
;    xs))
;
;; try splitting a string by multiple literals first, like ',' and ';'
;
;
;(local tt "woo {% 1 + 2 %} raw text 42 {{ {{ a-_.rst }}.colo }}")
;
;(print (tt:find ))
;
;(local pa (pp! tt))
;(print "")
;(pretty pa)


;(local temp (fs.read "/home/sean/.garden/etc/test.d/testrc.petal"))


;(->> temp
;     (parse)
;     (render)
;     (install))


; i'm not gonna convert it, my beautiful rec render stays
;{{  {{   a }}.b    }}
;get(get("a")..".b")

















