(local fetch (require :fetch))

(local sandbox {})

(fn meta [k v]
  "set add tuple of 'k' and 'v' to meta"
  (values "" [k v]))

(fn sandbox.get [s]
  "fetch value"
  (fetch s))

(fn sandbox.getenv [s]
  "fetch environmental variable"
  (os.getenv s))

(setmetatable sandbox
  {:__index (fn [self k v] (fn [v] (meta k v)))})

sandbox
