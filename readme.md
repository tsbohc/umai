# umai
A .files management tool and a templating engine with a twist: there's no configuration file.

umai takes a template, renders it to a separate folder, and symlinks the result to the target location specified within the template itself.

umai is meant to be scripted and extended.

## features

### minimalist
- written in fennel, a lisp that compiles to lua
- binary is a single lua script, no dependencies
- nearly 0-config

### templating
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
  - can be used for additional instructions, such as post install hooks

## examples
```bash
# bashrc
export UMAI_VARSETS_DIR="$HOME/.garden/varsets"
export UMAI_colo="limestone"
```
```bash
# ~/.garden/test.d/testrc.umai
{% softlink "~/.config/testrc" %}
cyan: "#{% {{colo}.cyan} %}"
```
```bash
# ~/.garden/varsets/limestone
cyan: 87c0b0
```
After running `umai testrc.umai`:
```yaml
# ~/.config/testrc
cyan: "#87c0b0"
```

## scripting
Make exporting variables easier:
```bash
umai-export() {
  export "UMAI_$1"="$2"
}
```

Use umai interactively with fzf:
```bash
umai-interactive() { 
  umai "$(find $dotfiles -type f -name '*.umai' | fzf)"
}
```

## thanks
- kikito for [sandbox.lua](https://github.com/kikito/sandbox.lua) and [memoize.lua](https://github.com/kikito/memoize.lua)
- Olical for [aniseed.core](https://github.com/Olical/aniseed)

# WIP
