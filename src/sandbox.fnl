(local fetch (require :fetch))

(local sandbox {})

(fn sandbox.target [s]
  "set target metadata field"
  (values "" {:target s}))

(fn sandbox.get [s]
  "fetch value"
  (fetch s))

(fn sandbox.getenv [s]
  "fetch environmental variable"
  (os.getenv s))

sandbox
