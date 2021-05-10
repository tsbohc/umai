(local expose {})

(tset expose :state {})

(fn expose.set [k v]
  (tset expose.state k v))

expose
