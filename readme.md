# blossom
A .files management tool with a twist: most of its configuration is embedded in the .files themselves. 

Think of it as making your .files aware what they have to contain, where to get it, and where to head afterwards. A minimal configuration file, or a lack thereof, paired with powerful templating, encourages composition over inheritance.

## example

```yaml
# config.yml
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
