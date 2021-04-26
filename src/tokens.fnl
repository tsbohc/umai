(local core  (require :core))
(local lexis (require :lexis))
(local get   (require :get))

(local tokens {})

(fn has-tokens? [s]
  "check if string 's' contains a {token}"
  (if (s:find lexis.token-re) true false))


(fn compile-single [s]
  "compile a {token} in string 's'"
  (let [key (s:match lexis.token-re)
        val (get key)]
    (pick-values 1 (s:gsub (lexis.token-esc key) val))))


(fn tokens.compile [s]
  "recursively compile {tokens} in string 's'"
  ; TODO: check for max recursion depth?
  (if (has-tokens? s)
    (tokens.compile (compile-single s))
    s))

tokens
