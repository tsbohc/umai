; manages blossom's grammar

; TODO: implementation still naive
; include _'s and -'s in names
; think about usage first, then rewrite

(local g
  {:pattern-l "{%-" :pattern-r "-%}" ; rename: env?
   :token-l   "{"   :token-r     "}"})

; handle escaped?
;(local m
;  {:token {:l "{%-" :r "-%}"}})

(local lexis {})

(fn lexis.pattern-esc [s]
  (.. (g.pattern-l:escape) s (g.pattern-r:escape)))

(fn lexis.pattern-lit [s]
  (.. (g.pattern-l) s (g.pattern-r)))

(fn lexis.token-esc [s]
  (.. (g.token-l:escape) s (g.token-r:escape)))

(fn lexis.token-lit [s]
  (.. (g.token-l) s (g.token-r)))

(tset lexis :pattern-re
  (lexis.pattern-esc "(.-)"))

(tset lexis :token-re
  (lexis.token-esc "([%w.]+)"))

(tset lexis :token-re-new "({[%w.{}]+})")
(tset lexis :env "({%%..-.%%})")

(tset lexis :statement "{%  %}")
(tset lexis :expression "{}")

(tset lexis :statement-re "({%% .- %%})")
(tset lexis :expression-re "({[%w._%-{}]+})")

lexis
