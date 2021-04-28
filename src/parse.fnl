(local core (require :core))
(local lexis (require :lexis))
(local parse {})

; TODO: warn instead of erroring when {}'s couldn't be rendered

;(fn find-next [s xs]
;  (var x 1e308)
;  (var y 1)
;  (each [_ p (ipairs xs)]
;    (let [(_x _y) (s:find p)]
;      (when (and (not= nil _x) (< _x x))
;        (set x _x)
;        (set y _y))))
;  (when (not= x 1e308)
;    (values x y)))
;
;
;(fn parse.parse [s]
;  (var s s)
;  (var done? false)
;  (let [xs []]
;    (while (not done?)
;      (let [(x y) (find-next s [lexis.statement-re lexis.expression-re])]
;        (when (not= x nil)
;          (table.insert xs (s:sub 1 (- x 1)))
;          (table.insert xs (s:sub x y))
;          (set s (s:sub (+ y 1))))
;        (when (core.nil? x)
;          (set done? true))))
;    (when (> (core.count s) 0)
;      (table.insert xs s))
;    xs))


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
