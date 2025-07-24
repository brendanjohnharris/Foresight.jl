```@meta
CurrentModule = Foresight
```

```@setup foresight
using CairoMakie
using CairoMakie.Makie.PlotUtils
using CairoMakie.Colors
using Makie
using Foresight
showable(::MIME"text/plain", ::AbstractVector{C}) where {C<:Colorant} = false
showable(::MIME"text/plain", ::PlotUtils.ContinuousColorGradient) = false
```

# Colors

The Foresight colors are `cornflowerblue`, `crimson`, `cucumber`, `california`, `juliapurple`.

```@example foresight
Foresight.colors
```

# Colormaps

## Sunrise

```@example foresight
sunrise # hide
```

## Cyclic Sunrise

```@example foresight
cyclicsunrise # hide
```

## Sunset

```@example foresight
sunset # hide
```

## Dark Sunset

```@example foresight
darksunset # hide
```

## Light Sunset

```@example foresight
lightsunset # hide
```

## Binary Sunset

```@example foresight
binarysunset # hide
```

## Cyclic

```@example foresight
cyclic # hide
```

## Pelagic

```@example foresight
pelagic # hide
```