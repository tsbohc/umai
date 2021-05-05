(local lexis
  {:e-l "{"   :e-r   "}"
   :s-l "{% " :s-r " %}"})

(set lexis.statement-re
     (.. "(" (lexis.s-l:escape) ".-" (lexis.s-r:escape) ")"))

(set lexis.expression-re
     (.. (lexis.e-l:escape) "([%w._%-]+)" (lexis.e-r:escape)))

lexis
