# Foresight.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://brendanjohnharris.github.io/Foresight.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://brendanjohnharris.github.io/Foresight.jl/dev/)
[![Build Status](https://github.com/brendanjohnharris/Foresight.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/brendanjohnharris/Foresight.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/brendanjohnharris/Foresight.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/brendanjohnharris/Foresight.jl)

A Makie theme. And some cool utilities.
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


# Utilities

### seethrough

Converts a color gradient into a transparent version.

```julia
C = cgrad(:viridis)
transparent_gradient = seethrough(C)
```

### widen

Slightly widens an interval by a fraction δ.

```julia
x = (0.0, 1.0)
wider_interval = Foresight.widen(x, 0.1)
```

### freeze!

Freezes the axis limits of a Makie figure.
```julia
fig, ax, plt = scatter(rand(10), rand(10))
freeze!(ax)
```

### clip

Copies a Makie figure to the clipboard.
```julia
fig = Figure()
scatter!(fig[1, 1], rand(10), rand(10))
clip(fig)
```

### @importall

Imports all symbols from a module into the current scope. Use with caution.
```julia
@importall(Foresight) .|> eval
```

### hidexaxis! and hideyaxis!

Hides the x-axis or y-axis, respectively, of a given axis object.
```julia
fig, ax, plt = scatter(rand(10), rand(10))
hidexaxis!(ax)
hideyaxis!(ax)
```

### gtkshow

Displays a CairoMakie scene, axis, figure, or FigureAxisPlot in a new GTK window. If Gtk is loaded, this is the default display method for CairoMakie figures. Useful for X-forwarding CairoMakie outputs from e.g. a remote cluster.
```julia
using CairoMakie, Gtk
using Foresight
scene = CairoMakie.Scene()
gtkshow(scene)
```

