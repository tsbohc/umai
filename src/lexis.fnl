(local g
  {:t-l "{"   :t-r   "}"
   :s-l "{% " :s-r " %}"})

(local lexis
  {:statement     (.. g.s-l g.s-r)
   :expression    (.. g.t-l g.t-r)
   :statement-re  (.. "(" (g.s-l:escape) ".-" (g.s-r:escape) ")")
   :expression-re (.. "(" (g.t-l:escape) "[%w._%-{}]+" (g.t-r:escape) ")")
   :token-re      (.. (g.t-l:escape) "([%w._%-]+)" (g.t-r:escape))})

(fn lexis.token-esc [s]
  (.. (g.t-l:escape) s (g.t-r:escape)))

lexis
