# blossom
A .files management tool with a twist: there is no configuration file. Almost everything is embedded in the .files themselves, the rest is handled through environmental variables.

## features
A single lua script with no extra dependencies, nearly 0-config.

#### templating
Blossom evaluates `{tokens}` recursively, up to any level of nesting. Values are fetched from environmental variables or xdefaults-like varsets. There's no need to convert colorschemes to a different format.

## example

```yaml
# config.petal
{%-
cyan: "#{{colo}.cyan}"
-%}
```
```bash
# .bashrc
blossom_colo="limestone"
```
```yaml
# varsets/limestone
cyan: 87c0b0
```
```yaml
# config.yml  
cyan: "#87c0b0"
```

## WIP
