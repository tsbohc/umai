(local core (require :core))
(local lexis (require :lexis))
(local parse {})

(fn parse.parse [s]
  (var s s)
  (var done? false)
  (let [xs []]
    (while (not done?)
      (let [(x y) (s:find lexis.statement-re)]
        (when (not= nil x)
          (table.insert xs (s:sub 1 (- x 1)))
          (table.insert xs (s:sub x y))
          (set s (s:sub (+ y 1))))
        (when (= nil x)
          (set done? true))))
    (when (> (core.count s) 0)
      (table.insert xs s))
    xs))


(setmetatable parse {:__call (fn [_ ...] (parse.parse ...))})

parse
