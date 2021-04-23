; {{{
; # blossom
; A .files management tool with a twist: 99% of the configuration is embedded in the .files themselves. Paired with powerful templating, this encourages composition over inheritance.

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



; step 1, get raw template
; color1: "#{@:-[colo].color1-:@}"

; step 2, make a substitution dictionary
; {@:-[colo].color1-:} = "[colo].color1"

; step 3, compile tokens
; {@:-[colo].color1-:} = "colo_val.color1"

; step 4, compile value
; {@:-[colo].color1-:} = "ff0000"

; step 5, perform substitution on raw template
; color1: "#ff0000"
; }}}

; TODO:
; - find a better way to use grammar and (lit), sting:lit?
; - lush support
; - environmenal variables insead of configuration?

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

; haunted
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

(global __cache {})
(macro memoize [f ...]
  `(do
     (if (nil? (. _G.__cache ,(tostring f ...)))
       (tset _G.__cache ,(tostring f) ,f ,...))
     (. _G.__cache ,(tostring f))))

;(macro if-let)
;(macro when-let)


(defn lit [s]
  "literalize string for regular expressions"
  (s:gsub
    "[%(%)%.%%%+%-%*%?%[%]%^%$]"
    (fn [c] (.. "%" c))))

(defn split [s d]
  "split string 's' by delimiter 'd' and return a table"
  (let [s (.. s d)
        xs []]
    (each [m (s:gmatch (.. "(.-)" (lit d)))]
      (% xs m))
    xs))

(defn nil? [v]
  (= v nil))

(defn string? [v]
  (= (type v) :string))

(defn seq? [xs]
  (var i 0)
  (each [_ (pairs xs)]
    (set i (+ i 1))
    (if (nil? (. xs i))
      (lua "return false")))
  true)

(defn contains? [xt y]
  (if (seq? xt)
    (each [_ v (ipairs xt)]
      (when (= v y)
        (lua "return true")))
    (when (not= nil (. xt y))
      (lua "return true")))
  false)

(defn pretty-print [...]
  (print (inspect ...)))

; }}}

; __exposed is a singleton, but nothing modifies it apart from this function
; it's just a shortcut for configuration
(defn expose [xt]
  (if (nil? _G.__exposed)
    (global __exposed {}))
  (each [k v (pairs xt)]
    (% __exposed k v)))

(global grammar
  {:p {:l "{@:-" :r "-:@}"}
   :e {:l "{@!-" :r "-!@}"}
   :v {:l "["    :r    "]"}})

; --- varset ---

(defn varset-list []
  "retrieve varsets list"
  (with-open
    [file (assert (io.popen "find varsets -type f" "r"))]
    (let [xs []]
      (each [line (file:lines)]
        (% xs (pick-values 1 (line:gsub "varsets/" ""))))
      xs)))


(defn varset [name]
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

(fn get-node [xt dots]
  "retrieve value from table 'xt' by 'dots' dot-path"
  (var v xt)
  (when (string? dots)
    (each [w (dots:gmatch "[%w_]+")]
      (if (nil? v) nil (set v (. v w))))
    (tostring v)))


(fn value [dots]
  "find value by 'dots', a dot separated path, in __exposed or varsets.
  token_value.value => 10"
  (let [root (or (dots:match "(%a+)%.") dots)
        path (dots:gsub (.. root (lit ".")) "")]
    (or ; remove and handle returns in get-node
      (if (contains? __exposed root)
        (get-node __exposed dots)
        (contains? (memoize (varset-list)) root)
        (let [varset (memoize (varset root))]
          (get-node varset path)))
      "")))

(defn tokens [pattern]
  "parse 'pattern' string and compile tokens.
  [token].value -> token_value.value"
  (let [dec-l (. grammar :v :l)
        dec-r (. grammar :v :r)
        token-re (.. (lit dec-l) "(.-)" (lit dec-r))]
    (var compiled pattern)
    (each [token (pattern:gmatch token-re)]
      (->> token
           (value)
           (compiled:gsub (.. (lit dec-l) token (lit dec-r)))
           (set compiled)))
    compiled))


(defn patterns [template]
  "takes 'template' raw string and return a substitution dictionary.
  foo: {{ [token].value }} ... -> { '{{ [token].value }}' = 10 }"
  (let [dec-l (. grammar :p :l)
        dec-r (. grammar :p :r)
        pattern-re (.. (lit dec-l) "(.-)" (lit dec-r))
        xt {}]
    (each [pattern (template:gmatch pattern-re)]
      (->> pattern
           ; TODO: merge those so that i can just (compile-pattern "-pat-string")
           ; keep them as separate functions though
           ; would be cool to have one function and just call it with or without []'s
          (tokens) ; make initial pass to compile [tokens]
          (value) ; make second pass to compile varset.vars
          (% xt (.. dec-l pattern dec-r))))
    ; TODO: where to put compile errors?
    xt))


(defn slurp [path]
  "return file contents as a string, accepts 'path'"
  (with-open
    [file (io.open path "r")]
    (let [s (file:read "*a")]
      s)))


(expose
  {:colo "kohi"
   ;:colo "lush"
   ;:lush (require :lush)
   :font "fira"
   :fonts { :fira { :normal 10 }}})


(defn compile [template dict]
  (var compiled template)
  (each [key val (pairs dict)]
    (set compiled (compiled:gsub (lit key) val)))
  compiled)


(defn dec [s d lit?]
  ; FIXME: current implementation is naive
  (local grammar
    {:pat {:l "{%- " :r " -%}"}   ; pattern
     :exp {:l "{@!-" :r "-!@}"}   ; expression
     :var {:l "{"    :r    "}"}}) ; token

  (let [l (if lit?
            (lit (. grammar d :l))
            (. grammar d :l))
        r (if lit?
            (lit (. grammar d :r))
            (. grammar d :r))]
    (.. l s r)))


(defn testing []
  (var test
    {:beverage "coffee"
     :mood "happy"
     :emoji { :happy "uwu" :sad "-w-"}
     :dessert { :name "waffles" :garnish "cherry jam"}
     :ff0000 "waffle"})


  ; TODO: check for mismatched brackets?

  ; --- compile patterns ---

  ; distilled recursive magic
  (defn has-expr? [s]
    (let [expr-re (dec "([%w.]+)" :var true)]
      (if (s:find expr-re) true false)))

  (defn compile [pat]
    (let [expr-re (dec "([%w.]+)" :var true)
          key (pat:match expr-re)
          val (get-node test key)]
      (pat:gsub (dec key :var true) val)))

  (defn rec-compile [pat]
    ; check for max recursion depth?
    (if (has-expr? pat)
      (rec-compile (compile pat))
      pat))

  ; TODO: just define capture groups somewhere for patterns, vars, etc...

  (var tt "{%- {beverage} and {dessert.name} with {dessert.garnish}! {emoji.{mood}} -%}")

  (defn patterns [s]
    (let [pat-re (dec "(.-)" :pat true)
          xt {}]
      (each [pat (s:gmatch pat-re)]
        (tset xt (dec pat :pat) (rec-compile pat)))
      xt))

  (->> tt
       (patterns)
       (pretty-print))






)

(testing)
























;  (defn rec-parse [pat]
;    (print "---")
;    (var ppat pat)
;    (print (.. "in: " pat))
;    (if (has-expr? pat)
;      (let [va-re (dec "(%a+)" :var true)]
;        (print "ya")
;        (each [va (pat:gmatch va-re)]
;          (let [value (get-node test va)
;                pat (pat:gsub (dec va :var true) value)]
;            (print (.. "re: " pat))
;            (rec-parse pat))))
;      ppat))
;  (print (rec-parse "{colo}"))

