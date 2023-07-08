```@meta
CurrentModule = Foresight
```

# Foresight

Documentation for [Foresight](https://github.com/brendanjohnharris/Foresight.jl).

```@index
```

```@setup foresight
using CairoMakie
using CairoMakie.Makie.PlotUtils
using CairoMakie.Colors
using Foresight
showable(::MIME"text/plain", ::AbstractVector{C}) where {C<:Colorant} = false
showable(::MIME"text/plain", ::PlotUtils.ContinuousColorGradient) = false
```

```@example foresight
a = 1
b = 2
a+b
```

```@autodocs
Modules = [Foresight]
```
