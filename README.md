# Foresight.jl
A Makie theme
# Usage
```Julia
using CairMakie
using Foresight
foresight() |> Makie.set_theme!
fig = Foresight.demofigure()
```
![demo](test/demo.png)

## Theme options
Any combination of the keywords below can be used to customise the theme.
### Dark
```Julia
foresight(:dark) |> Makie.set_theme!
fig = Foresight.demofigure()
```
![demo](test/demo_dark.png)

### Transparent
```Julia
foresight(:dark, :transparent) |> Makie.set_theme!
fig = Foresight.demofigure()
```
![demo](test/demo_transparentdark.png)

### Serif
```Julia
foresight(:serif) |> Makie.set_theme!
fig = Foresight.demofigure()
```
![demo](test/demo_serif.png)
