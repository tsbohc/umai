# umai
A .files management tool and a templating engine with a twist: there's no configuration file.

umai takes a template, renders it to a separate folder, and symlinks the result to the target location specified within the template itself.

umai is meant to be scripted and extended.

## features

### minimalist
- written in fennel, a lisp that compiles to lua
- binary is a standalone lua script
- nearly 0-config

## usage
```
```

## examples
```bash
# bashrc
umai!() {
  umai --varsets "~/.garden/etc/umai.d/" "$@" - \
       "$(find ~/.garden/etc -type f -name "*.umai")"
}
```
```bash
# ~/.garden/test.d/testrc.umai
{% softlink "~/.config/testrc.yml" %}
cyan: "#{% {{colo}.cyan} %}"
```
```bash
# ~/.garden/etc/umai.d/limestone
cyan: 87c0b0
```
After running `umai! -colo limestone`:
```yaml
# ~/.config/testrc.yml
cyan: "#87c0b0"
```

## scripting
Use umai interactively with fzf:
```bash
umai-fzf() {
  umai --varsets "~/.garden/etc/umai.d" "$@" - \
      "$(find ~/.garden/etc -type f -name '*.umai' | fzf)"
}
```

## thanks
- kikito for [sandbox.lua](https://github.com/kikito/sandbox.lua) and [memoize.lua](https://github.com/kikito/memoize.lua)
- Olical for [aniseed.core](https://github.com/Olical/aniseed)

# WIP
