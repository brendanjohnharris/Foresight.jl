```@meta
CurrentModule = Foresight
```

```@setup foresight
using CairoMakie
using CairoMakie.Makie.PlotUtils
using CairoMakie.Colors
using Makie
using Foresight
using Statistics
import Makie.Linestyle
showable(::MIME"text/plain", ::AbstractVector{C}) where {C<:Colorant} = false
showable(::MIME"text/plain", ::PlotUtils.ContinuousColorGradient) = false
Makie.set_theme!(Foresight.foresight())
```


# Recipes

## [ziggurat](@ref)

```@shortdocs; canonical=false
ziggurat
```

```@example foresight
x = randn(100)
ziggurat(x)
```

## [hill](@ref)

```@shortdocs; canonical=false
hill
```

```@example foresight
x = randn(100)
hill(x)
```


## [kinetic](@ref)

```@shortdocs; canonical=false
kinetic
```

```@example foresight
x = -π:0.1:π
kinetic(x, sin.(x), linewidth=:curv)
```


## [bandwidth](@ref)

```@shortdocs; canonical=false
bandwidth
```

```@example foresight
x = -π:0.1:π
bandwidth(x, sin.(x); bandwidth = sin.(x))
```

## [polarhist](@ref)

```@shortdocs; canonical=false
polarhist
```

```@example foresight
polarhist(randn(1000) .* 2)
```

## [polardensity](@ref)

```@shortdocs; canonical=false
polardensity
```

```@example foresight
polardensity(randn(1000) .* 2;
                 strokewidth = 5,
                 strokecolor = :angle,
                 strokecolormap = cyclic,
                 colormap=:viridis)
```

## [covellipse](@ref)

```@shortdocs; canonical=false
covellipse
```

```@example foresight
xy = randn(100, 2) * [1 1; 0 0.5]
μ = mean(xy, dims = 1)
Σ² = cov(xy)

fig, ax, plt = covellipse(ax, μ, Σ²)
scatter!(ax, xy)
fig
```

## prism

```@docs; canonical=false
prism
```

```@example foresight
ys = sin.((0:0.001:(π * 1.5)) .+ (0.1:0.1:(2π))')
Σ² = cov(ys .+ randn(size(ys)) ./ 10; dims = 1)
H = prism(Σ²; palette = [cornflowerblue, crimson]) # Generates the prism colors

f = Figure()
limits = (0, maximum(abs.(Σ²))) # You must set the limits manually
g, ax = prismplot!(f[1, 1], H; limits, colorbarlabel = "Covariance magnitude")
axislegend(ax,
            [
                PolyElement(color = (cornflowerblue, 0.7)),
                PolyElement(color = (crimson, 0.7))
            ],
            ["PC 1", "PC 2"], position = :lt)
ax.xlabel = ax.ylabel = "Variable"
f
```
