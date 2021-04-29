(require-macros :macros)

(local core  (require :core))
(local fs (require :fs))
(local expose (require :expose))
(local parse (require :parse))
(local render (require :render))
(local install (require :install))
(local petals (require :petals))

;(tset package :path (.. package.path ";/home/sean/.local/share/nvim/site/pack/packer/start/lush.nvim/lua/?.lua"))
;(tset package :path (.. package.path ";/home/sean/.local/share/nvim/site/pack/packer/start/kohi/lua/lush_theme/?.lua"))


; TODO:
; custom file ext? like .umai. what about ft?
; add getenv to sandbox

; get rid of expose, again?
; use root varset and env variables instead of expose
; definitely env for .garden/etc and varsets

; maybe make it so that .garden/etc/umai/varsets
; and .garden/etc/umai/root <- "exposed" varset

; clean up get, maybe rename to fetch to prevent name clash with get, get-in, get-dp
; clean up lexis
; clean up macros, remove global weirdness?
; remove petals? <- combine varset and petals

; clean up and refactor in general

; write tests

; FIXME: LUSH

(expose {:ENV "/home/sean/.garden/etc"})

(local se {})

(set se.ENV "/home/sean/.garden/etc")
(set se.colo "kohi")

(expose se)

(fn make [path]
  (print (.. "installing: " path))
  (->> path
       (fs.read)
       (parse)
       (render)
       (install)))

(core.map make (petals))
