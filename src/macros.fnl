; TODO: move those to core
(fn nil? [v] `(= ,v nil))
(fn string? [v] `(= (type ,v) :string))
(fn table? [v] `(= (type ,v) :table))
(fn number? [v] `(= (type ,v) :number))

(fn seq? [v]
  `(core.seq? ,v))

(fn has? [xt y]
  `(core.has? ,xt ,y))

(fn when-not [cond ...]
  `(when (not ,cond)
     ,...))

(fn if-not [cond ...]
  `(if (not ,cond)
     ,...))

(fn memoize [name ...]
  "uses memoize.lua"
  `(local ,name (core.memoize (fn ,...))))

(fn pretty [...]
  `(print (core.inspect ,...)))

(fn import [name]
  `(local ,name (require ,(tostring name))))

(fn map [...] `(core.map ,...))

(fn ?? [e r]
  `(do
     (print (.. "test: " ,e " " ,(tostring r)))
     (if (= ,e ,r)
       (print "pass")
       (do
         (print (.. "expected '" (core.inspect ,e) "', received '" (core.inspect ,r) "'"))))
     (print "")))

{
 : ??
 : import
 : nil?
 : string?
 : table?
 : number?
 : seq?
 : has?
 : when-not
 : if-not
 : memoize
 : pretty
 : map
 }
