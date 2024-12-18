# Foresight.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://brendanjohnharris.github.io/Foresight.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://brendanjohnharris.github.io/Foresight.jl/dev/)
[![Build Status](https://github.com/brendanjohnharris/Foresight.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/brendanjohnharris/Foresight.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/brendanjohnharris/Foresight.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/brendanjohnharris/Foresight.jl)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.14511387.svg)](https://doi.org/10.5281/zenodo.14511387)

A Makie theme. And some cool utilities.
# Usage
```Julia
using CairoMakie
using Foresight
foresight() |> Makie.set_theme!
fig = Foresight.demofigure()
```
![demo](test/demos/demo.png)

## Theme options
Any combination of the keywords below can be used to customise the theme.
### Dark
```Julia
foresight(:dark, :transparent) |> Makie.set_theme!
fig = Foresight.demofigure()
```
![demo](test/demos/dark.png)

### Transparent
```Julia
foresight(:dark, :transparent) |> Makie.set_theme!
fig = Foresight.demofigure()
```
![demo](test/demos/transparent.png)

### Serif
```Julia
foresight(:serif) |> Makie.set_theme!
fig = Foresight.demofigure()
```
![demo](test/demos/serif.png)

### Physics
```Julia
foresight(:physics) |> Makie.set_theme!
fig = Foresight.demofigure()
```
![demo](test/demos/physics.png)

# Utilities

### addlabels!

Add labels to a provided grid layout, automatically searching for blocks to label.

```julia
f = Foresight.demofigure()
addlabels!(f)
display(f)
```

### seethrough

Converts a color gradient into a transparent version.

```julia
C = cgrad(:viridis)
transparent_gradient = seethrough(C)
```

### scientific

Generate string representation of a number in scientific notation with a specified number of significant digits.

```julia
scientific(1/123.456, 3) # "8.10 × 10⁻³"
```

There is also an `lscientific` method, which returns a LaTeX string:
```julia
lscientific(1/123.456, 3) # "8.10 \\times 10^{-3}"
```

### brighten and darken

Brighten a color by a given factor by blending it with white:

```julia
brighten(:cornflowerblue, 0.2) # Brightens the color by 20%
```

Or, darken a color by blending it with black:
```julia
darken(:cornflowerblue, 0.2) # Darkens the color by 20%
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

# Colors
The theme is based on the colors `[cornflowerblue, crimson, cucumber, california, juliapurple]`:

![palette](test/palette.svg)

It also provides the following colormaps:
#### sunrise
![sunrise](test/colormaps/sunrise.svg)
#### cyclicsunrise
![cyclicsunrise](test/colormaps/cyclicsunrise.svg)
#### sunset
![sunset](test/colormaps/sunset.svg)
#### darksunset
![darksunset](test/colormaps/darksunset.svg)
#### lightsunset
![lightsunset](test/colormaps/lightsunset.svg)
#### binarysunset
![binarysunset](test/colormaps/binarysunset.svg)
#### cyclic
![cyclic](test/colormaps/cyclic.svg)
#### pelagic
![pelagic](test/colormaps/pelagic.svg)

# Recipes
The following recipes are exported:

### ziggurat

A transparent stepped histogram, shown in the demo figure above.

### hill

A transparent kernel density plot, shown in the demo figure above.

### prism

Colors a positive definite matrix according to its eigendecomposition.
![prism](test/recipes/prism_light.png#gh-light-mode-only)
![prism](test/recipes/prism_dark.png#gh-dark-mode-only)

### covellipse

Plot an ellipse representing a given covariance matrix.
![prism](test/recipes/covellipse_light.png#gh-light-mode-only)
![prism](test/recipes/covellipse_dark.png#gh-dark-mode-only)

