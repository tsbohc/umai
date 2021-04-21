# blossom
A .files management tool with a twist: most of its configuration is embedded in the .files themselves. 

Think of it as making your .files aware what they have to contain, where to get it, and where to head afterwards. A minimal configuration file, or a lack thereof, paired with powerful templating, encourages composition over inheritance.

## example

```yaml
# config.yml
{{! target = '~/.config/config.yml' !}}
cyan: '#{{ [colo].cyan }}'
```
```clojure
; blossom.fnl
(expose
  {:colo "limestone"})
```
```yaml
# varsets/limestone
cyan: 87c0b0
```
Blossom will step through the patterns, first evaluating the `[tokens]` and then inserting the values themselves:
```yaml
# config.yml  
cyan: '#87c0b0'
```
It's worth noting, that `[tokes]` can also be evaluted through varsets.

After being rendered, the file will be symlinked to `~/.config/config.yml`, due to executing `target` assignment.

## WIP
