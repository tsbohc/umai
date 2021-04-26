(require-macros :macros)

(local core  (require :core))
(local tokens (require :tokens))
(local fs (require :fs))
(local lexis (require :lexis))

; TODO:
; rename tokens to compile? ambiguity?
; infile varset declaration?
; custom file ext? like .petal? what about ft?
; check for mismatched brackets? count both {} and compare

;(local get (require :get))
;(pretty (get :kohi.color1))

;(var tt "{%- {kohi.color2} {{colo}.color1} {beverage} and {dessert.name} with {dessert.garnish}! {emoji.{mood}} -%}")
;(var tt "{%- {{colo}.color1} -%}")
;(print (tokens.compile tt))

(local petals (require :petals))

(fn patterns [s]
  (let [xt {}]
    (each [pattern (s:gmatch lexis.pattern-re)]
      (tset xt pattern (tokens.compile pattern)))
    xt))

(each [_ petal (ipairs (petals))]
  (let [content (fs.slurp petal)]
    (pretty (patterns content))))

