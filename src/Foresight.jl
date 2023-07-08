module Foresight

using Makie
using Makie.Formatting
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

export foresight, importall, freeze!, clip, hidexaxis!, hideyaxis!, axiscolorbar, scientific, lscientific


const cornflowerblue = colorant"#6495ED"
export cornflowerblue
const _cornflowerblue = colorant"#3676E8"
export _cornflowerblue
const crimson = colorant"#DC143C"
export crimson
const _crimson = colorant"#ED365B"
export _crimson
const cucumber = colorant"#77ab58"
export cucumber
const _cucumber = colorant"#5F8A46"
export _cucumber
const california = colorant"#EF9901"
export california
const _california = colorant"#FEB025"
export _california
const copper = colorant"#c37940"
export copper
const _copper = colorant"#9E6132"
export _copper
const juliapurple = colorant"#9558b2"
export juliapurple
const _juliapurple = colorant"#7A4493"
export _juliapurple
const keppel = colorant"#46AF98"
export keppel
const _keppel = colorant"#66C2AE"
export _keppel
const darkbg = colorant"#282C34"
export darkbg
const _darkbg = colorant"#3E4451"
export _darkbg
const greyseas = colorant"#cccccc"
export greyseas
const _greyseas = colorant"#eeeeee"
export _greyseas
cyclical = cgrad([california, crimson, cornflowerblue, cucumber, california], [0, 0.2, 0.5, 0.8, 1])
export cyclical
sunrise = cgrad([crimson, california, cucumber, cornflowerblue], [0.2, 0.4, 0.6, 0.8])
export sunrise
sunset = reverse(cgrad([crimson, juliapurple, cornflowerblue], [0, 0.6, 1]))
export sunset

"""
    seethrough(C::ContinuousColorGradient, start=0.5, stop=1.0)

Convert a color gradient into a transparent version

# Examples
```julia
C = sunrise;
transparent_gradient = seethrough(C)
```
"""
function seethrough(C::Makie.PlotUtils.ContinuousColorGradient, start=0.5, stop=1.0)
    colors = C.colors
    alphas = LinRange(start, stop, length(colors))
    return cgrad([RGBA(RGB(c), a) for (c, a) in zip(colors, alphas)], C.values)
end
export seethrough

"""
    brighten(c::T, β)

Brighten a color `c` by a factor of `β` by blending it with white. `β` should be between 0 and 1.

# Example
```julia
brighten(cornflowerblue, 0.5)
```
"""
function brighten(c::T, β) where T
    b = RGBA(c)
    b = RGBA(1, 1, 1, b.alpha)
    cb = cgrad([c, b])
    return convert(T, cb[β])
end

"""
    darken(c::T, β)

Darken a color `c` by a factor of `β` by blending it with black. `β` should be between 0 and 1.

# Example
```julia
darken(cornflowerblue, 0.5)
```
"""
function darken(c::T, β) where T
    b = RGBA(c)
    b = RGBA(0, 0, 0, b.alpha)
    cb = cgrad([c, b])
    return convert(T, cb[β])
end
export brighten, darken

# * A good font
foresightfont() = "Arial"
foresightfont(f::Symbol) = foresightfont(Val(f))
foresightfont(::Val{:bold}) = foresightfont()*" Bold"
foresightfont(::Val{:italic}) = foresightfont()*" Italic"
foresightfont(s::String) = foresightfont()*" "

foresightfontsize() = 16
# foresightfont_bold() = "Helvetica Bold"

"""
Slightly widen an interval by a fraction δ
"""
function widen(x, δ=0.05)
    @assert length(x) == 2
    Δ = diff(x |> collect)[1]
    return x .+ δ * Δ .* [-1, 1]
end

"""
    default_theme!(thm)

Set the default theme to `thm` and save it as a preference. The change will take effect after restarting Julia.

# Example
```julia
default_theme!(foresight())
```
"""
macro default_theme!(thm)
    try
        @set_preferences!("default_theme" => string(thm))
        @info("Default theme set to $thm. Restart Julia for the change to take effect")
    catch e
        @error "Could not set theme. Reverting to Foresight.jl default"
    end
end
export @default_theme!
_default_theme = @load_preference("default_theme", default = "foresight()")
function default_theme()
    try
        eval(Meta.parse(_default_theme))
    catch e
        @error "Could not load theme. Reverting to Foresight.jl default"
        return foresight()
    end
end

function __init__()
    @eval Makie.set_theme!(default_theme())

    # @static if !isdefined(Base, :get_extension)
    @require Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80" begin
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
    f = Figure()
    ax = Axis(f[1, 1], title="measurements", xlabel="time (s)", ylabel="amplitude")
    labels = ["alpha", "beta", "gamma", "delta", "epsilon", "zeta"]
    for i in 1:6
        y = cumsum(randn(10)) .* (isodd(i) ? 1 : -1)
        lines!(y, label=labels[i])
        scatter!(y, label=labels[i])
    end
    Legend(f[1, 2], ax, "legend", merge=true)
    Axis3(f[1, 3], viewmode=:stretch, zlabeloffset=40, title="Variable: σ⟿𝑡")
    s = Makie.surface!(0:0.5:10, 0:0.5:10, (x, y) -> sqrt(x * y) + sin(1.5x))
    Colorbar(f[1, 4], s, label="intensity")
    ax = Axis(f[2, 1:2], title="different species", xlabel="height (m)", ylabel="density",)
    for i in 1:6
        y = randn(200) .+ 2i
        Makie.density!(y)
    end
    tightlimits!(ax, Bottom())
    Makie.xlims!(ax, -1, 15)
    Axis(f[2, 3:4], title="stock performance", xticks=(1:6, labels), xlabel="company", ylabel="gain (\$)", xticklabelrotation=pi / 6)
    for i in 1:6
        data = randn(1)
        barplot!([i], data)
        rangebars!([i], data .- 0.2, data .+ 0.2, color=:gray41)
    end
    return f
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
function freeze!(ax::Union{Axis,Axis3})
    limits = ax.finallimits.val
    limits = zip(limits.origin, limits.origin .+ limits.widths)
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
function clip(fig=Makie.current_figure(), fmt=:png; kwargs...)
    freeze!(fig)
    tmp = tempname() * "." * string(fmt)
    Makie.save(tmp, fig; kwargs...)
    img = load(tmp)
    clipboard_img(img)
    return tmp
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
    exp = names(eval(mdl), all=true)
    return [:(import $fullname.$e) for e in exp]
end

function hidexaxis!(ax::Axis)
    ax.xticksvisible = false
    ax.xticklabelsvisible = false
    ax.xlabelvisible = false
end

function hideyaxis!(ax::Axis)
    ax.yticksvisible = false
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
function scientific(x::Real, sigdigits=2)
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

    unicode_exponent = join(['⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹'][parse(Int, digit) + 1] for digit in exponent)

    formatted = split(formatted, " ")[1] * " " * split(formatted, " ")[2] * " 10" * neg * unicode_exponent
end

"""
    lscientific(x::Real, sigdigits=2)

Return a string representation of a number in scientific notation with a specified number of significant digits. This is _not_ an L-string.

# Example
```julia
lscientific(1/123.456, 3) # "8.10 \\times 10^{-3}"
```
"""
function lscientific(x::Real, sigdigits=2)
    formatted = fmt(".$(sigdigits-1)e", x)
    formatted = replace(formatted, "e+0" => "e+")
    formatted = replace(formatted, "e-0" => "e-")
    formatted = replace(formatted, "e+" => "e")

    s = replace(formatted, "e" => "\\times 10^{")

    s = s*"}"
end



colororder = [(cornflowerblue, 0.7),
    (crimson, 0.7),
    (cucumber, 0.7),
    (california, 0.7),
    (juliapurple, 0.7)]
palette = (
    patchcolor=colororder,
    color=colororder,
    strokecolor=colororder)



function _foresight(; globalfont=foresightfont(), globalfontsize=foresightfontsize())
    Theme(;
        colormap=sunrise,
        strokewidth=10.0,
        strokecolor=:black,
        strokevisible=true,
        font=globalfont,
        fonts=(; regular=globalfont, bold=foresightfont(:bold), italic=foresightfont(:italic)),
        palette,
        linewidth=5.0,
        fontsize=globalfontsize,
        Figure=(;
            resolution=(720, 480),
        ),
        Axis=(;
            backgroundcolor=:white,
            xgridcolor=:gray88,
            ygridcolor=:gray88,
            xminorgridcolor=:gray91,
            # xminorgridvisible = true,
            yminorgridcolor=:gray91,
            # yminorgridvisible = true,
            leftspinevisible=false,
            rightspinevisible=false,
            bottomspinevisible=false,
            topspinevisible=false,
            xminorticksvisible=false,
            yminorticksvisible=false,
            xticksvisible=false,
            yticksvisible=false,
            spinewidth=1,
            xticklabelcolor=:black,
            yticklabelcolor=:black,
            titlecolor=:black,
            xticksize=4,
            yticksize=4,
            xtickwidth=1.5,
            ytickwidth=1.5,
            xgridwidth=1.5,
            ygridwidth=1.5,
            xlabelpadding=3,
            ylabelpadding=3,
            palette,
            titlefont=string(globalfont) * " bold", # "times serif bold",
            xticklabelfont=globalfont,
            yticklabelfont=globalfont,
            xlabelfont=globalfont,
            ylabelfont=globalfont,
            titlesize=20
        ),
        Legend=(;
            framevisible=false,
            padding=(0, 0, 0, 0),
            patchcolor=:transparent,
            titlefont=string(globalfont) * " Bold",
            labelfont=globalfont
        ),
        Axis3=(;
            xgridcolor=:gray81,
            ygridcolor=:gray81,
            zgridcolor=:gray81,
            xspinesvisible=false,
            yspinesvisible=false,
            zspinesvisible=false,
            yzpanelcolor=:white,
            xzpanelcolor=:white,
            xypanelcolor=:white,
            xticksvisible=false,
            yticksvisible=false,
            zticksvisible=false,
            titlefont=string(globalfont) * " Bold",
            xticklabelfont=globalfont,
            yticklabelfont=globalfont,
            zticklabelfont=globalfont,
            xlabelfont=globalfont,
            ylabelfont=globalfont,
            zlabelfont=globalfont,
            titlesize=20,
            palette
        ),
        Colorbar=(;
            tickcolor=:white,
            tickalign=1,
            ticklabelcolor=:black,
            spinewidth=0,
            ticklabelpad=5,
            ticklabelfont=globalfont,
            labelfont=globalfont
        ),
        Textbox=(;
            font=globalfont
        ),
        Scatter=(; palette),
        Lines=(; palette),
        Hist=(; palette),
        Label=(; valign=:top, halign=:left, font=:bold, fontsize=24)
    )
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
"""
function foresight(options...; font=foresightfont())
    if :serif ∈ options
        thm = _foresight(; globalfont="CMU")
    else
        thm = _foresight(; globalfont=font)
    end
    options = collect(options)
    options = options[options.!=:serif]
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
    strokecolor = textcolor = :white
    setall!(thm, :strokecolor, strokecolor)
    setall!(thm, :backgroundcolor, darkbg)
    setall!(thm, :textcolor, textcolor)
    setall!(thm, :xgridcolor, gridcolor)
    setall!(thm, :ygridcolor, gridcolor)
    setall!(thm, :zgridcolor, gridcolor)
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
    thm[:Axis3][:xspinesvisible] = false
    thm[:Axis3][:yspinesvisible] = false
    thm[:Axis3][:zspinesvisible] = false
    thm[:Axis3][:xticksvisible] = false
    thm[:Axis3][:yticksvisible] = false
    thm[:Axis3][:zticksvisible] = false
end


"""
    axiscolorbar(ax, args...; kwargs...)

Create a colorbar for the given `ax` axis. The `args` argument is passed to the `Colorbar` constructor, and the `kwargs` argument is passed to the `Colorbar` constructor as keyword arguments. The `position` argument specifies the position of the colorbar relative to the axis, and can be one of `:rt` (right-top), `:rb` (right-bottom), `:lt` (left-top), `:lb` (left-bottom). The default value is `:rt`.

# Example
```julia
f = Figure()
ax = Axis(f[1, 1])
x = -5:0.01:5
plot!(ax, x, x->sinc(x), color=1:length(x), colormap=sunset)
axiscolorbar(ax; label="Time (m)")
```
"""
function axiscolorbar(ax, args...; position=:rt, kwargs...)
    C = Colorbar(ax.parent, args...;
        bbox=ax.scene.px_area,
        Makie.legend_position_to_aligns(position)...,
        kwargs...)
    if !isempty(C.label[])
        ax.alignmode = Mixed(right=75);
    end
end



include("RedBlue.jl")
include("Polar.jl")

end
