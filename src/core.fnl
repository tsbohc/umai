(tset
  (getmetatable "")
  :__index :escape
  (fn [s]
    "escape string for regular expressions"
    (s:gsub "[%(%)%.%%%+%-%*%?%[%]%^%$]"
            (fn [c] (.. "%" c)))))

(local core {})

(fn core.nil? [x]
  (= nil x))

(fn core.table? [x]
  (= "table" (type x)))

(fn core.seq? [xs]
  "check if table is a sequence"
  (var i 0)
  (each [_ (pairs xs)]
    (set i (+ i 1))
    (if (= nil (. xs i))
      (lua "return false")))
  true)

(fn core.has? [xt y]
  "check if table contains a value or a (k, v) pair"
  (if (core.seq? xt)
    (each [_ v (ipairs xt)]
      (when (= v y)
        (lua "return true")))
    (when (not= nil (. xt y))
      (lua "return true")))
  false)

(fn core.even? [n]
  (= (% n 2) 0))

(fn core.odd? [n]
  (not (core.even? n)))

(fn core.count [xs]
  "count elements in seq or characters in string"
  (if
    (core.table? xs)
    (do
      (var maxn 0)
      (each [k v (pairs xs)]
        (set maxn (+ maxn 1)))
      maxn)
    (not xs) 0
    (length xs)))

(fn core.run! [f xs]
  "execute the function (for side effects) for every xs."
  (when xs
    (let [nxs (core.count xs)]
      (when (> nxs 0)
        (for [i 1 nxs]
          (f (. xs i)))))))

(fn core.map [f xs]
  "map xs to a new seq by calling (f x) on each item."
  (let [result []]
    (core.run!
      (fn [x]
        (let [mapped (f x)]
          (table.insert
            result
            (if (= 0 (select "#" mapped))
              nil
              mapped))))
      xs)
    result))

(fn core.reduce [f init xs]
  "reduce xs into a result by passing each subsequent value into the fn with
  the previous value as the first arg. Starting with init."
  (var result init)
  (core.run!
    (fn [x]
      (set result (f result x)))
    xs)
  result)

(fn core.merge! [base ...]
  (core.reduce
    (fn [acc m]
      (when m
        (each [k v (pairs m)]
          (tset acc k v)))
      acc)
    (or base {})
    [...]))

(fn core.merge [...]
  (core.merge! {} ...))

(fn core.get [xt k d]
  "retrieve value from 'xt' by 'k', fall back to 'd'"
  (let [res (when (core.table? xt)
              (. xt k))]
    (if (core.nil? res) d res)))

(fn core.get-in [xt ks d]
  "retrieve value from 'xt' by 'ks' [k1 k2 ...], fall back to 'd'"
  (let [res (core.reduce
              (fn [acc k]
                (when (core.table? acc)
                  (core.get acc k)))
              xt ks)]
    (if (core.nil? res) d res)))

(fn core.get-dp [xt s d]
  "retrieve value from 'xt' by 's' k1.k2..., fall back to 'd'"
  (let [ks []]
    (each [w (s:gmatch "[%w_]+")]
      (table.insert ks w))
    (core.get-in xt ks d)))

(set core.inspect (require :lib.inspect))
(set core.memoize (require :lib.memoize))
(set core.setfenv (require :lib.setfenv))

core
