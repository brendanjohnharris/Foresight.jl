```@meta
CurrentModule = Foresight
```

```@setup foresight
using CairoMakie
using CairoMakie.Makie.PlotUtils
using CairoMakie.Colors
using Makie
using Foresight
```

# Foresight

Documentation for [Foresight](https://github.com/brendanjohnharris/Foresight.jl); a Makie theme and some utilities.


## Default theme
```@example foresight
using CairoMakie
using Foresight
foresight() |> Makie.set_theme!
fig = Foresight.demofigure()
```

## Theme options
Any combination of the keywords below can be used to customise the theme.
### Dark
```@example foresight
foresight(:dark, :transparent) |> Makie.set_theme!
fig = Foresight.demofigure()
```

### Transparent
```@example foresight
foresight(:dark, :transparent) |> Makie.set_theme!
fig = Foresight.demofigure()
```

### Serif
```@example foresight
foresight(:serif) |> Makie.set_theme!
fig = Foresight.demofigure()
```

### Physics
```@example foresight
foresight(:physics) |> Makie.set_theme!
fig = Foresight.demofigure()
```