(require-macros :macros)
(local core (require :core))

; TODO:
; check for mismatched brackets?
; just define capture groups somewhere for patterns, vars, etc...

; FIXME: get rid of this global, globals bad
(global __exposed 
  {:colo "kohi"
   :beverage "coffee"
   :mood "happy"
   :emoji { :happy "uwu" :sad "-w-"}
   :dessert { :name "waffles" :garnish "cherry jam"}
   :ff0000 "waffle"})


; TODO: separate into module
(lambda lex [x ?y ?z]
  "library of all blossom's lexical data.
  decorate 'x' with '?z' raw '?y'"
  ; could probably be written more concisely and efficiently
  (let [pat-l "{%-" pat-r "-%}"
        token-l "{"   token-r   "}"]
    (if (nil? ?y)
      (match x
        :pat-re (.. (pat-l:escape) "(.-)" (pat-r:escape))
        :token-re (.. (token-l:escape) "([%w.]+)" (token-r:escape))
        _ (error (.. "lex contains no such key: " x)))
      (match ?y
        :pat (.. (if ?z pat-l (pat-l:escape)) x (if ?z pat-r (pat-r:escape)))
        :token (.. (if ?z token-l (token-l:escape)) x (if ?z token-r (token-r:escape)))
        _ (error (.. "lex contains no such key: " ?y))))))


(fn slurp [path]
  "return file contents as a string, accepts 'path'"
  (with-open
    [file (io.open path "r")]
    (let [s (file:read "*a")]
      s)))


(memoize varset-list []
  "retrieve varsets list"
  (with-open
    [file (assert (io.popen "find varsets -type f" "r"))]
    (let [xs []]
      (each [line (file:lines)]
        (table.insert xs (pick-values 1 (line:gsub "varsets/" ""))))
      xs)))


; TODO: make (varset) return false when there isn't one
(memoize varset [name]
  "return a varset table by [name]"
  (with-open
    [file (assert (io.open (.. "varsets/" name) "r"))]
    (let [comment-re "%s*!"
          keyval-re  "(%w+):%s*(%w+)"
          xt {}]
      (each [line (file:lines)]
        (when-not (or (line:match comment-re) (= line ""))
          (let [(key val) (line:match keyval-re)]
            (tset xt key val))))
      xt)))

; --- compile patterns ---

(fn get-node [xt dots]
  "retrieve value from table 'xt' by 'dots' dot-path"
  ; fixme why are we even handling outfut here?
  ; this should work regardless of what the value type is
  (var v xt)
  (when (string? dots)
    (each [w (dots:gmatch "[%w_]+")]
      (if (nil? v) nil (set v (. v w))))
    (if-not (or (number? v) (string? v))
      (error (.. "token '" dots "' could not be compiled"))
      v)))


; FIXME: this is far too wonky and needs a redone along with get-node
(fn token-value [dots]
  "find value by 'dots', a dot separated path, in __exposed or varsets.
  token_value.value => 10"
  (let [root (or (dots:match "(%w+)%.") dots)
        root-re (.. root ".")
        root-re (root-re:escape)
        path (dots:gsub root-re "")]
    (or ; remove and handle returns in get-node
      (if (has? __exposed root)
        (get-node __exposed dots)
        (has? (varset-list) root)
        (let [varset (varset root)]
          (get-node varset path)))
      "")))

; distilled recursive magic
(fn tokens? [s]
  "check if string 's' contains a {token}"
  (if (s:find (lex :token-re)) true false))

(fn compile-token [s]
  "compile a {token} in string 's'"
  (let [key (s:match (lex :token-re))
        val (token-value key)]
    (pick-values 1 (s:gsub (lex key :token) val))))

(fn compile-tokens [s]
  "compile {tokens} in string 's'"
  ; TODO: check for max recursion depth?
  (if (tokens? s)
    (compile-tokens (compile-token s))
    s))


(var tt "{%- {{colo}.color1} {beverage} and {dessert.name} with {dessert.garnish}! {emoji.{mood}} -%}")

(print (compile-tokens tt))

;(fn patterns [s]
;  (let [pat-re (dec "(.-)" :pat true)
;        xt {}]
;    (each [pat (s:gmatch pat-re)]
;      (tset xt (dec pat :pat) (compile-tokens pat)))
;    xt))
;
;(->> tt
;     (patterns)
;     (pretty-print))
