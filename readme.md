# umai
A .files management tool and a templating engine with a twist: there's no configuration file.

umai will search a directory tree for .umai templates, render each of them to a separate folder, and symlink the results to the target locations specified within the templates themselves.

## features

#### minimalist
- written in fennel, a lisp that compiles to lua
- binary is a single lua script, no dependencies
- nearly 0-config

#### templating
- expressions
  - have implicit contexts, no need to specify where to pull values from
  - contexts range from varsets to environmental variables
  - support any level of nesting
- statements
  - sandboxed evaluation of any arbitrary lua code
  - extendable sandbox
- varsets
  - xdefaults-like datasets that provide context to templates
- metadata
  - templates determine their own metadata during evaluation
  - used for additional instructions, such as post install hooks

## example

```
# .files/testrc.umai
{% target "~/.config/testrc" %}
cyan: "#{% {{colo}.cyan} %}"
```
```
# varsets/root
colo: limestone
```
```
# varsets/limestone
cyan: 87c0b0
```
Result:
```
# ~/.config/testrc
cyan: "#87c0b0"
```

## WIP
