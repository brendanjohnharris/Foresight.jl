module Foresight

using Makie
using Format
using Colors
using Random
# using Images
using ImageClipboard
using FileIO
using Preferences
using Makie.LaTeXStrings

# if !isdefined(Base, :get_extension)
using Requires
# end

export foresight, importall, freeze!, clip, hidexaxis!, hideyaxis!, axiscolorbar,
       scientific, lscientific

include("Colors.jl")
include("Recipes.jl")

"""
    seethrough(C::ContinuousColorGradient, start=0.0, stop=1.0)

Convert a color gradient into a transparent version

# Examples
```julia
C = sunrise;
transparent_gradient = seethrough(C)
```
"""
function seethrough(C::Makie.PlotUtils.ContinuousColorGradient, start = 0, stop = 1.0)
    colors = C.colors
    alphas = LinRange(start, stop, length(colors))
    return cgrad([RGBA(RGB(c), a) for (c, a) in zip(colors, alphas)], C.values)
end
seethrough(C, args...) = seethrough(cgrad(C), args...)
seethrough(C::Makie.Color, args...) = seethrough(cgrad([C, C]), args...)
export seethrough

"""
    brighten(c::T, β)

Brighten a color `c` by a factor of `β` by blending it with white. `β` should be between 0 and 1.

# Example
```julia
brighten(cornflowerblue, 0.5)
```
"""
function brighten(c::T, β::AbstractFloat) where {T}
    b = RGBA(c)
    b = RGBA(1, 1, 1, b.alpha)
    cb = cgrad([c, b])
    return convert(T, cb[β])
end

function lighten(c, a)
    c = parse(RGB, c)
    return RGB((1 - a) + a * c.r), RGB((1 - a) + a * c.g), RGB((1 - a) + a * c.b)
end

"""
    darken(c::T, β)

Darken a color `c` by a factor of `β` by blending it with black. `β` should be between 0 and 1.

# Example
```julia
darken(cornflowerblue, 0.5)
```
"""
function darken(c::T, β::AbstractFloat) where {T}
    b = RGBA(c)
    b = RGBA(0, 0, 0, b.alpha)
    cb = cgrad([c, b])
    return convert(T, cb[β])
end
export brighten, darken

# * A good font
foresightfont() = "Arial"
foresightfont(f::Symbol) = foresightfont(Val(f))
foresightfont(::Val{:bold}) = foresightfont() * " Bold"
foresightfont(::Val{:italic}) = foresightfont() * " Italic"
foresightfont(s::String) = foresightfont() * " "

foresightfontsize() = 18
# foresightfont_bold() = "Helvetica Bold"

"""
Slightly widen an interval by a fraction δ
"""
function widen(x, δ = 0.05)
    @assert length(x) == 2
    Δ = diff(x |> collect)[1]
    return x .+ δ * Δ .* [-1, 1]
end

"""
    @default_theme!(thm)

Set the default theme to `thm` and save it as a preference. The change will take effect after restarting Julia.

# Example
```julia
    @default_theme!(foresight())
```
"""
macro default_theme!(thm)
    try
        @set_preferences!("default_theme"=>string(thm))
        @info("Default theme set to $thm. Restart Julia for the change to take effect")
    catch e
        @error "Could not set theme. Reverting to Foresight.jl default"
    end
end
export @default_theme!
_default_theme = @load_preference("default_theme", default="foresight()")
function default_theme()
    try
        eval(Meta.parse(_default_theme))
    catch e
        @error "Could not load theme. Reverting to Foresight.jl default"
        return foresight()
    end
end

function __init__()
    # @eval Makie.set_theme!(default_theme())
    # @static if !isdefined(Base, :get_extension)
    @require Plots="91a5bcdd-55d7-5caf-9e0b-520d859cae80" begin
        include("../ext/PlotsExt.jl")
    end
    # @require Gtk="4c0ca9eb-093a-5379-98c5-f87ac0bbbf44" begin
    #     @require CairoMakie="13f3f980-e62b-5c42-98c6-ff1f3baf88f0" @eval include("../ext/CairoMakieExt.jl")
    # end
    # end
end

"""
    demofigure()

Produce a figure showcasing the current theme.
"""
function demofigure()
    Random.seed!(32)
    f = Figure(size = (1080, 640))
    ax = Axis(f[1, 1], title = "Measurements", xlabel = "Time (s)", ylabel = "Amplitude")
    labels = [L"\alpha", L"\beta", L"\gamma", L"\delta", L"\epsilon", L"\zeta"]
    for i in 1:6
        y = cumsum(randn(10)) .* (isodd(i) ? 1 : -1)
        lines!(y, label = labels[i])
        scatter!(y, label = labels[i])
    end
    Legend(f[1, 2], ax, "Legend", merge = true, nbanks = 2)
    Axis3(f[1, 3], viewmode = :stretch, zlabeloffset = 40, title = "Variable: σ ⤆ τ")
    s = Makie.surface!(0:0.5:10, 0:0.5:10, (x, y) -> sqrt(x * y) + sin(1.5x),
                       colormap = sunrise)
    Colorbar(f[1, 4], s, label = "Intensity")
    ax = Axis(f[2, 1:2], title = "Different species", xlabel = "Height (m)",
              ylabel = "Density")
    for i in 1:6
        y = randn(200) .+ 2i
        hill!(y)
    end
    tightlimits!(ax, Bottom())
    Makie.xlims!(ax, -1, 15)
    Axis(f[2, 3:4], title = "Stock performance", xticks = (1:6, labels), xlabel = "Company",
         ylabel = "Gain (\$)")
    for i in 1:6
        data = randn(1)
        barplot!([i], data)
        rangebars!([i], data .- 0.2, data .+ 0.2, color = :gray41)
    end

    ax = Makie.Axis(f[1, 5], title = "Dogs vs. cats")
    tightlimits!(ax)
    for i in 1:3
        y = randn(200) .+ 2i
        ziggurat!(y)
    end

    ax = Makie.Axis(f[2, 5], title = "Strange attractor") # From the Makie docs for datashader
    function trajectory(fn, x0, y0, kargs...; n = 1000) #  kargs = a, b, c, d
        xy = zeros(Point2f, n + 1)
        xy[1] = Point2f(x0, y0)
        @inbounds for i in 1:n
            xy[i + 1] = fn(xy[i], kargs...)
        end
        return xy
    end
    Clifford((x, y), a, b, c, d) = Point2f(sin(a * y) + c * cos(a * x),
                                           sin(b * x) + d * cos(b * y))
    arg = [0, 0, -1.7, 1.5, -0.5, 0.7]
    points = trajectory(Clifford, arg...; n = Int(5e6))
    datashader!(ax, points, async = false,
                colormap = cgrad([:transparent, cornflowerblue, darkbg], [0, 0.4, 1]))
    f
end

freeze!(anything) = ()
"""
    freeze!(ax::Union{Axis, Axis3, Figure}=current_figure())
Freeze the limits of an Axis or Axis3 object at their current values.

# Example
```julia
ax = Axis();
plot!(ax, -5:0.01:5, x->sinc(x))
freeze!(ax)
```
"""
function freeze!(ax::Union{Axis, Axis3})
    limits = ax.finallimits.val
    limits = zip(limits.origin, limits.origin .+ limits.widths)
    limits = (first(limits)..., last(limits)...)
    ax.limits = limits
    limits
end
freeze!(f::Figure) = freeze!.(f.content)
freeze!() = freeze!(current_figure())

"""
    tmpfile = clip(fig=Makie.current_figure(), fmt=:png; kwargs...)

Save the current figure to a temporary file and copy it to the clipboard. `kwargs` are passed to `Makie.save`.

# Example
```julia
f = plot(-5:0.01:5, x->sinc(x))
clip(f)
```
"""
function clip(fig = Makie.current_figure(), fmt = :png; kwargs...)
    freeze!(fig)
    tmp = tempname() * "." * string(fmt)
    Makie.save(tmp, fig; kwargs...)
    img = load(tmp)
    try
        clipboard_img(img)
    catch e
        @warn "Could not copy to clipboard"
    end
    return tmp
end

function beep()
    try
        sound(f) = [`play -q -n synth 0.1 sin $f`]
        @async [run.(sound(f)) for f in [500, 250, 450, 250, 425, 250, 500]]
        ()
    catch
    end
end

"""
    importall(module)

Return an array of expressions that can be used to import all names from a module.

# Example
```julia
importall(module) .|> eval
```
"""
function importall(mdl)
    mdl = eval(mdl)
    fullname = Symbol(mdl)
    exp = names(eval(mdl), all = true)
    return [:(import $fullname.$e) for e in exp]
end

function hidexaxis!(ax::Axis)
    ax.xticksvisible = false
    ax.xminorticksvisible = false
    ax.xticklabelsvisible = false
    ax.xlabelvisible = false
end

function hideyaxis!(ax::Axis)
    ax.yticksvisible = false
    ax.yminorticksvisible = false
    ax.yticklabelsvisible = false
    ax.ylabelvisible = false
end

"""
    scientific(x::Real, sigdigits=2)

Return a string representation of a number in scientific notation with a specified number of significant digits.

# Arguments
- `x::Real`: The number to be formatted.
- `sigdigits::Int=2`: The number of significant digits to display.

# Returns
A string representation of the number in scientific notation with the specified number of significant digits.

# Example
```julia
scientific(1/123.456, 3) # "8.10 × 10⁻³"
```
"""
function scientific(x::Real, sigdigits = 2)
    formatted = fmt(".$(sigdigits-1)e", x)
    formatted = replace(formatted, "e+0" => "e+")
    formatted = replace(formatted, "e-0" => "e-")
    formatted = replace(formatted, "e+" => "e")
    formatted = replace(formatted, "e" => " × 10^")

    # To display unicode superscripts for exponent
    exponent = split(formatted, "^")[2]
    if exponent[1] == '-'
        neg = "⁻"
        exponent = exponent[2:end]
    else
        neg = ""
    end

    unicode_exponent = join(['⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹'][parse(Int, digit) + 1]
                            for digit in exponent)

    formatted = split(formatted, " ")[1] * " " * split(formatted, " ")[2] * " 10" * neg *
                unicode_exponent
end

"""
    lscientific(x::Real, sigdigits=2)

Return a string representation of a number in scientific notation with a specified number of significant digits. This is _not_ an L-string.

# Example
```julia
lscientific(1/123.456, 3) # "8.10 \\times 10^{-3}"
```
"""
function lscientific(x::Real, sigdigits = 2)
    formatted = fmt(".$(sigdigits-1)e", x)
    formatted = replace(formatted, "e+0" => "e+")
    formatted = replace(formatted, "e-0" => "e-")
    formatted = replace(formatted, "e+" => "e")

    s = replace(formatted, "e" => "\\times 10^{")

    s = s * "}"
end

colororder = [(cornflowerblue, 0.7),
    (crimson, 0.7),
    (cucumber, 0.7),
    (california, 0.7),
    (juliapurple, 0.7)]
palette = (patchcolor = colororder,
           color = colororder,
           strokecolor = colororder)

function _foresight(; globalfont = foresightfont(), globalfontsize = foresightfontsize())
    Theme(;
          colormap = sunrise,
          strokewidth = 10.0,
          strokecolor = :cornflowerblue,
          strokevisible = true,
          font = globalfont,
          fonts = (; regular = globalfont, bold = foresightfont(:bold),
                   italic = foresightfont(:italic)),
          palette,
          linewidth = 5.0,
          patchstrokewidth = 0.0,
          markersize = 15,
          fontsize = globalfontsize,
          Figure = (;
                    size = (720, 480)),
          Axis = (;
                  backgroundcolor = :white,
                  topspinecolor = :gray88,
                  leftspinecolor = :gray88,
                  bottomspinecolor = :gray88,
                  rightspinecolor = :gray88,
                  xgridcolor = :gray88,
                  ygridcolor = :gray88,
                  xminorgridcolor = :gray91,
                  # xminorgridvisible = true,
                  yminorgridcolor = :gray91,
                  # yminorgridvisible = true,
                  leftspinevisible = false,
                  rightspinevisible = false,
                  bottomspinevisible = false,
                  topspinevisible = false,
                  xminorticksvisible = false,
                  yminorticksvisible = false,
                  xticksvisible = false,
                  yticksvisible = false,
                  spinewidth = 1,
                  xticklabelcolor = :black,
                  yticklabelcolor = :black,
                  titlecolor = :black,
                  xticksize = 4,
                  yticksize = 4,
                  xtickwidth = 1.5,
                  ytickwidth = 1.5,
                  xgridwidth = 1.5,
                  ygridwidth = 1.5,
                  xlabelpadding = 3,
                  ylabelpadding = 3,
                  palette,
                  titlefont = string(globalfont) * " bold", # "times serif bold",
                  xticklabelfont = globalfont,
                  yticklabelfont = globalfont,
                  xlabelfont = globalfont,
                  ylabelfont = globalfont,
                  titlesize = 20),
          Legend = (;
                    framevisible = false,
                    padding = (0, 0, 0, 0),
                    patchcolor = :transparent,
                    titlefont = string(globalfont) * " Bold",
                    labelfont = globalfont),
          Axis3 = (;
                   spinecolor = :gray81,
                   xgridcolor = :gray81,
                   ygridcolor = :gray81,
                   zgridcolor = :gray81,
                   xspinesvisible = false,
                   yspinesvisible = false,
                   zspinesvisible = false,
                   yzpanelcolor = :white,
                   xzpanelcolor = :white,
                   xypanelcolor = :white,
                   xticksvisible = false,
                   yticksvisible = false,
                   zticksvisible = false,
                   titlefont = string(globalfont) * " Bold",
                   xticklabelfont = globalfont,
                   yticklabelfont = globalfont,
                   zticklabelfont = globalfont,
                   xlabelfont = globalfont,
                   ylabelfont = globalfont,
                   zlabelfont = globalfont,
                   titlesize = 20,
                   palette),
          Colorbar = (;
                      spinecolor = :gray88,
                      tickcolor = :white,
                      tickalign = 1,
                      ticklabelcolor = :black,
                      spinewidth = 0,
                      ticklabelpad = 5,
                      ticklabelfont = globalfont,
                      labelfont = globalfont),
          Textbox = (;
                     font = globalfont),
          Scatter = (; palette),
          Lines = (; palette),
          Hist = (; palette),
          Density = (; palette, strokewidth = 5,
                     cycle = Cycle([:color, :strokecolor], covary = true)),
          Label = (; valign = :top, halign = :left, font = :bold, fontsize = 24))
end

"""
    foresight(options...; font=foresightfont())

Return the default Foresight theme. The `options` argument can be used to modify the default values, by passing keyword arguments with the names of the attributes to be changed and their new values.

Some vailable options are:
- `:dark`: Use a dark background and light text.
- `:transparent`: Make the background transparent.
- `:minorgrid`: Show minor gridlines.
- `:serif`: Use a serif font.
- `:redblue`: Use a red-blue colormap.
- `:gray`: Use a grayscale colormap.
- `:physics`: Set a theme that resembles typical plots in physics journals.
"""
function foresight(options...; font = foresightfont())
    if :serif ∈ options
        thm = _foresight(; globalfont = "Times")
    else
        thm = _foresight(; globalfont = font)
    end
    options = collect(options)
    options = options[options .!= :serif]
    _foresight!.((thm,), Val.(options))
    return thm
end

四海 = 遠見 = 四看 = fourseas = foresight

function setall!(thm::Attributes, attribute, value)
    thm[attribute] = value
    for a in keys(thm)
        if thm[a] isa Attributes
            if value isa Attributes
                thm[a] = value
            else
                thm[a][attribute] = value
            end
        end
    end
end

transparent = Makie.RGBA(0, 0, 0, 0)
function _foresight!(thm::Attributes, ::Val{:transparent})
    setall!(thm, :backgroundcolor, transparent)
    setall!(thm, :yzpanelcolor, transparent)
    setall!(thm, :xzpanelcolor, transparent)
    setall!(thm, :xypanelcolor, transparent)
end
function _foresight!(thm::Attributes, ::Val{:minorgrid})
    setall!(thm, :xminorgridvisible, true)
    setall!(thm, :yminorgridvisible, true)
    setall!(thm, :zminorgridvisible, true)
end
function _foresight!(thm::Attributes, ::Val{:dark})
    gridcolor = :gray38
    minorgridcolor = :gray51
    strokecolor = cornflowerblue
    textcolor = :white
    setall!(thm, :strokecolor, strokecolor)
    setall!(thm, :backgroundcolor, darkbg)
    setall!(thm, :textcolor, textcolor)
    setall!(thm, :xgridcolor, gridcolor)
    setall!(thm, :ygridcolor, gridcolor)
    setall!(thm, :zgridcolor, gridcolor)
    setall!(thm, :xtickcolor, gridcolor)
    setall!(thm, :ytickcolor, gridcolor)
    setall!(thm, :ztickcolor, gridcolor)
    setall!(thm, :xminorgridcolor, minorgridcolor)
    setall!(thm, :yminorgridcolor, minorgridcolor)
    setall!(thm, :zminorgridcolor, minorgridcolor)
    setall!(thm, :xticklabelcolor, textcolor)
    setall!(thm, :yticklabelcolor, textcolor)
    setall!(thm, :zticklabelcolor, textcolor)
    setall!(thm, :titlecolor, textcolor)
    setall!(thm, :yzpanelcolor, darkbg)
    setall!(thm, :xzpanelcolor, darkbg)
    setall!(thm, :xypanelcolor, darkbg)
    setall!(thm, :tickcolor, textcolor)
    setall!(thm, :ticklabelcolor, textcolor)
    setall!(thm, :spinecolor, gridcolor)
    thm[:Axis][:topspinecolor] = gridcolor
    thm[:Axis][:leftspinecolor] = gridcolor
    thm[:Axis][:bottomspinecolor] = gridcolor
    thm[:Axis][:rightspinecolor] = gridcolor
    thm[:Colorbar][:spinecolor] = gridcolor
    thm[:Axis3][:xspinesvisible] = false
    thm[:Axis3][:yspinesvisible] = false
    thm[:Axis3][:zspinesvisible] = false
    thm[:Axis3][:xticksvisible] = false
    thm[:Axis3][:yticksvisible] = false
    thm[:Axis3][:zticksvisible] = false
end
function _foresight!(thm::Attributes, ::Val{:physics})
    setall!(thm, :topspinevisible, true)
    setall!(thm, :rightspinevisible, true)
    setall!(thm, :bottomspinevisible, true)
    setall!(thm, :leftspinevisible, true)
    setall!(thm, :xticksvisible, true)
    setall!(thm, :yticksvisible, true)
    setall!(thm, :zticksvisible, true)
    setall!(thm, :xtickalign, true)
    setall!(thm, :ytickalign, true)
    setall!(thm, :ztickalign, true)
    setall!(thm, :xminortickalign, true)
    setall!(thm, :yminortickalign, true)
    setall!(thm, :zminortickalign, true)

    setall!(thm, :xminorticksvisible, true)
    setall!(thm, :yminorticksvisible, true)
    setall!(thm, :zminorticksvisible, true)
    setall!(thm, :xminorticks, IntervalsBetween(5))
    setall!(thm, :yminorticks, IntervalsBetween(5))
    setall!(thm, :zminorticks, IntervalsBetween(5))

    setall!(thm, :topspinecolor, :black)
    setall!(thm, :rightspinecolor, :black)
    setall!(thm, :bottomspinecolor, :black)
    setall!(thm, :leftspinecolor, :black)

    setall!(thm, :xgridvisible, false)
    setall!(thm, :ygridvisible, false)
    setall!(thm, :zgridvisible, false)
    setall!(thm, :xminorgridvisible, false)
    setall!(thm, :yminorgridvisible, false)
    setall!(thm, :zminorgridvisible, false)

    setall!(thm, :xminorgridstyle, :dash)
    setall!(thm, :yminorgridstyle, :dash)
    setall!(thm, :zminorgridstyle, :dash)

    thm[:Axis3][:xgridvisible] = true
    thm[:Axis3][:ygridvisible] = true
    thm[:Axis3][:zgridvisible] = true
end

"""
    axiscolorbar(ax, args...; kwargs...)

Create a colorbar for the given `ax` axis. The `args` argument is passed to the `Colorbar` constructor, and the `kwargs` argument is passed to the `Colorbar` constructor as keyword arguments. The `position` argument specifies the position of the colorbar relative to the axis, and can be one of `:rt` (right-top), `:rb` (right-bottom), `:lt` (left-top), `:lb` (left-bottom). The default value is `:rt`.

# Example
```julia
f = Figure()
ax = Axis(f[1, 1])
x = -5:0.01:5
p = plot!(ax, x, x->sinc(x), color=1:length(x), colormap=sunset)
axiscolorbar(ax, p; label="Time (m)")
```
"""
function axiscolorbar(ax, args...; position = :rt, kwargs...)
    C = Colorbar(ax.parent, args...;
                 bbox = ax.scene.px_area,
                 Makie.legend_position_to_aligns(position)...,
                 kwargs...)
    if !isempty(C.label[])
        ax.alignmode = Mixed(right = 75)
    end
end

include("RedBlue.jl")
include("Polar.jl")
include("Prism.jl")
include("CovEllipse.jl")
include("Layouts.jl")
if haskey(ENV, "FORESIGHT_PATCHES")
    include(joinpath(@__DIR__, "Patches.jl"))
end
end
