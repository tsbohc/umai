; forward declare with M?

(do
  (fn escape [s]
    "escape string for regular expressions"
    (pick-values 
      1 (s:gsub
          "[%(%)%.%%%+%-%*%?%[%]%^%$]"
          (fn [c] (.. "%" c)))))
  (let [mt (getmetatable "")]
    (tset mt :__index :escape escape)))


(fn seq? [xs]
  (var i 0)
  (each [_ (pairs xs)]
    (set i (+ i 1))
    (if (= nil (. xs i))
      (lua "return false")))
  true)


(fn has? [xt y]
  (if (seq? xt)
    (each [_ v (ipairs xt)]
      (when (= v y)
        (lua "return true")))
    (when (not= nil (. xt y))
      (lua "return true")))
  false)


{:inspect (require :inspect)
 :memoize (require :memoize)
 : seq?
 : has?}
