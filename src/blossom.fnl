; variables are not meant to be modified
; do not define vars inside functions
; -- not using local, var, or set in functions

; pure functions mutate nothing outside their scope & they're deterministic
; fns that return value should be called that (message) returns a message, not (new-message)
; functional programming encourages composing complex functions out of smaller ones
; fns up to around 10 lines long

; top level -- functions with side-effects that use
; bottom level -- pure functions

; -- naming conventions --
; (varset)  - returns a varset
; (my-fun!) - impure function (those with side-effects)
; (bool?)   - functions that return a boolean

; xs        - [v1 v2 v3 ...]
; xt        - {:k1 v1 :k2 v2 ...}
; s         - string
; x y       - numbers
; i index   - indexes
; n         - size
; f g h     - functions
; re        - regular expression

; override (. xt :key)
; to support (. xt :a.b.c) ? seems dumb now that i think about it

; dunno if it's an eyesore, there're bound to be some globals
(global __exposed {})
(global inspect (require :inspect))

; {{{ lib
(macro when-not [cond ...]
  `(when (not ,cond)
     ,...))

(macro if-not [cond ...]
  `(if (not ,cond)
     ,...))

(macro tset- [xs key val]
  `(when (= nil (. ,xs ,key))
     (tset ,xs ,key ,val)
     true))

(macro def- [name ...]
  `(when (= nil ,name)
     (var ,name ,...)
     true))

(macro global- [name ...]
  `(when (= nil ,name)
     (global ,name ,...)
     true))

; closure-like definitions, i'm not using var or global
(macro def [name value]
  `(local ,name ,value))

(macro defn [name ...]
  `(fn ,name ,...))

; because idk
(macro != [...]
  `(not= ,...))

; we're never using modulo in this
(macro % [tab key val]
  (if (not= nil val)
    `(tset ,tab ,key ,val)
    `(table.insert ,tab ,key)))

(macro expose [name value]
  `(tset _G.__exposed ,(tostring name) ,value))

;(macro if-let)
;(macro when-let)

(defn lit [s]
  "literalize string for regular expressions"
  (s:gsub
    "[%(%)%.%%%+%-%*%?%[%]%^%$]"
    (fn [c] (.. "%" c))))

(defn nil? [v]
  (= v nil))

(defn string? [v]
  (= (type v) :string))
; }}}

(defn pretty-print [...]
  (print (inspect ...)))

; --- definitions ---

; heirarchy & terms
; template:
;   patterns:
;     tokens

(global grammar
  {:p {:l "{@:-" :r "-:@}"}
   :e {:l "{@!-" :r "-!@}"}
   :v {:l "["    :r    "]"}})

; -- low level ---

; TODO: redo this in favor of (find  :key)
(fn get-node [node-path]
  (var v __exposed)
  (when (string? node-path)
    (each [w (node-path:gmatch "[%w_]+")]
      (if (nil? v) nil (set v (. v w))))
    v))

; seach for exposed vars, then load varset if needed and look there
(defn find [xs]
  )

(find [:a :b])

; --- varset ---

; TODO: implement 
; (cached? varset-list) -- check if cached
; (cache varset-list) --
; (get cache varset-list)

; FIXME: or just do memoization and stop nesting shit
; (memoize varset-list)
; run varset-list
; cache result
; reassign varset-list to just return cache

(defn varset-list []
  "retrieve varsets list once and returns it on subsequent calls"
  (when (nil? _G.__varset-list_cache)
    (with-open
      [file (assert (io.popen "find varsets -type f" "r"))]
      (let [xs []]
        (each [line (file:lines)]
          (% xs (pick-values 1 (line:gsub "varsets/" ""))))
        (global __varset-list_cache xs))))
  __varset-list_cache)


(defn varset [name]
  ; TODO: implement caching like with varsets
  "return a varset table by [name]"
  (with-open
    [file (io.open (.. "varsets/" name) "r")]
    (let [comment-re "%s*!"
          keyval-re  "(%w+):%s*(%w+)"
          xt {}]
      (each [line (file:lines)]
        (when-not (or (line:match comment-re) (= line ""))
          (let [(key val) (line:match keyval-re)]
            (% xt key val))))
      xt)))

; --- template ---

(defn template [path]
  "return file contents of template at [path] as a string"
  (with-open
    [file (io.open path "r")]
    (let [s (file:read "*a")]
      s)))


(defn compile-tokens [pattern]
  "parse [pattern] and return compiled string"
  (let [dec-l (. grammar :v :l)
        dec-r (. grammar :v :r)
        key-re (.. (lit dec-l) "(.-)" (lit dec-r))]
    ; FIXME: mutations
    (var parsed pattern)
    (each [key (pattern:gmatch key-re)]
      (let [val (get-node key) ]
        (set parsed (parsed:gsub (.. (lit dec-l) key (lit dec-r)) val))))
    parsed))


(defn patterns [template]
  "return a table of patterns from [template] string"
  (let [dec-l (. grammar :p :l)
        dec-r (. grammar :p :r)
        pattern-re (.. (lit dec-l) "(.-)" (lit dec-r))
        xt {}]
    (each [pattern (template:gmatch pattern-re)]
      (->> pattern
          (compile-tokens)
          ;(compile-pattern)
          (% xt (.. dec-l pattern dec-r))))
    xt))


(expose colo "kohi")
(expose font "fira")

(-> :testrc
    (template)
    (patterns)
    (pretty-print)
    )



;(print (get-node :g.foo))





;(-> :kohi
;    (varset)
;    (pretty-print)
