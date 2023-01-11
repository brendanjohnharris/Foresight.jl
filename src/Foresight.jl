module Foresight

using Makie
using Colors
using Random
# using Images
using ImageClipboard
using FileIO
using Requires
using Preferences

export foresight, importall, freeze!, clip, hidexaxis!, hideyaxis!


const cornflowerblue = colorant"#6495ED"; export cornflowerblue
const _cornflowerblue =  colorant"#3676E8"; export _cornflowerblue
const crimson = colorant"#DC143C"; export crimson
const _crimson = colorant"#ED365B"; export _crimson
const cucumber = colorant"#77ab58"; export cucumber
const _cucumber = colorant"#5F8A46"; export _cucumber
const california = colorant"#EF9901"; export california
const _california = colorant"#FEB025"; export _california
const copper = colorant"#c37940"; export copper
const _copper = colorant"#9E6132"; export _copper
const juliapurple = colorant"#9558b2"; export juliapurple
const _juliapurple = colorant"#7A4493"; export _juliapurple
const keppel = colorant"#46AF98"; export keppel
const _keppel = colorant"#66C2AE"; export _keppel
const darkbg = colorant"#282C34"; export darkbg
const _darkbg = colorant"#3E4451"; export _darkbg
const greyseas = colorant"#cccccc"; export greyseas
const _greyseas = colorant"#eeeeee"; export _greyseas
cyclical = cgrad([california, crimson, cornflowerblue, cucumber, california], [0, 0.2, 0.5, 0.8, 1]); export cyclical
sunrise = cgrad([crimson, california, cucumber, cornflowerblue], [0.2, 0.4, 0.6, 0.8]); export sunrise
sunset = reverse(cgrad([crimson, juliapurple, cornflowerblue], [0, 0.6, 1])); export sunset

"""
Convert a color gradient into a transparent version
"""
function seethrough(C::Makie.PlotUtils.ContinuousColorGradient, start=0.5, stop=1.0)
    colors = C.colors
    alphas = LinRange(start, stop, length(colors))
    return cgrad([RGBA(RGB(c), a) for (c, a) in zip(colors, alphas)], C.values)
end
export seethrough

# * A good font
foresightfont() = "TeX Gyre Heros"
# foresightfont_bold() = "Helvetica Bold"

"""
Slightly widen an interval by a fraction δ
"""
function widen(x, δ=0.05)
    @assert length(x) == 2
    Δ = diff(x|>collect)[1]
    return x .+ δ*Δ.*[-1, 1]
end

include("./foresight.jl")


macro default_theme!(thm)
    try
        @set_preferences!("default_theme" => string(thm))
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
    @eval Makie.set_theme!(default_theme())
    @require Plots="91a5bcdd-55d7-5caf-9e0b-520d859cae80" @eval include("Plots.jl")
end

function demofigure()
    Random.seed!(32)
    f = Figure()
    ax = Axis(f[1, 1], title = "measurements", xlabel = "time (s)", ylabel = "amplitude")
    labels = ["alpha", "beta", "gamma", "delta", "epsilon", "zeta"]
    for i in 1:6
        y = cumsum(randn(10)) .* (isodd(i) ? 1 : -1)
        lines!(y, label = labels[i])
        scatter!(y, label = labels[i])
    end
    Legend(f[1, 2], ax, "legend", merge = true)
    Axis3(f[1, 3], viewmode = :stretch, zlabeloffset = 40, title = "Variable: σ⟿𝑡")
    s = Makie.surface!(0:0.5:10, 0:0.5:10, (x, y) -> sqrt(x * y) + sin(1.5x))
    Colorbar(f[1, 4], s, label = "intensity")
    ax = Axis(f[2, 1:2], title = "different species", xlabel = "height (m)", ylabel = "density",)
    for i in 1:6
        y = randn(200) .+ 2i
        Makie.density!(y)
    end
    tightlimits!(ax, Bottom())
    Makie.xlims!(ax, -1, 15)
    Axis(f[2, 3:4], title = "stock performance", xticks = (1:6, labels), xlabel = "company", ylabel = "gain (\$)", xticklabelrotation = pi/6)
    for i in 1:6
        data = randn(1)
        barplot!([i], data)
        rangebars!([i], data .- 0.2, data .+ 0.2, color=:gray41)
    end
    return f
end;


freeze!(anything) = ()
function freeze!(ax::Union{Axis, Axis3})
    limits = ax.finallimits.val
    limits = zip(limits.origin, limits.origin .+ limits.widths)
end
freeze!(f::Figure) = freeze!.(f.content)
freeze!() = freeze!(current_figure())


"""
Copy a Makie figure to the clipboard
"""
function clip(fig=Makie.current_figure(), fmt=:png; kwargs...)
    freeze!(fig)
    tmp = tempname()*"."*string(fmt)
    Makie.save(tmp, fig; kwargs...)
    img = load(tmp)
    clipboard_img(img)
    return tmp
end

"""
Hacky way to import all symbols from a module into the current scope. Really only a half-good idea in the REPL, for debugging.
Use this as `importall(module) .|> eval`
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

end
