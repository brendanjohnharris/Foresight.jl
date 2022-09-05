module FourSeas

using Makie
using Colors
using Random
# using Images
using ImageClipboard
using FileIO
using Requires

function __init__()
    @require Plots="91a5bcdd-55d7-5caf-9e0b-520d859cae80" @eval include("Plots.jl")
end


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
const _greyseas = colorant"#eeeeee"; export _greayseas
const cyclical = cgrad(:cyclic_mygbm_30_95_c78_n256_s25); export cyclical
const sunset = cgrad([crimson, juliapurple, cornflowerblue], [0, 0.6, 1]); export sunset

# * A good font
fourseasfont() = :cmu

"""
Slightly widen an interval by a fraction δ
"""
function widen(x, δ=0.05)
    @assert length(x) == 2
    Δ = diff(x|>collect)[1]
    return x .+ δ*Δ.*[-1, 1]
end

include("./theme_fourseas.jl")
include("./theme_fourseasdark.jl")

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
        rangebars!([i], data .- 0.2, data .+ 0.2)
    end
    return f
end;

"""
Copy a Makie figure to the clipboard
"""
function clip(fig=Makie.current_figure(), fmt=:png; kwargs...)
    tmp = tempname()*"."*string(fmt)
    Makie.save(tmp, fig; kwargs...)
    img = load(tmp)
    clipboard_img(img)
    return tmp
end; export clip

"""
Hacky way to import all symbols from a module into the current scope. Really only a half-good idea in the REPL, for debugging.
"""
macro importall(mdl)
    fullname = Symbol(eval(mdl))
    exp = names(eval(mdl))
    [eval(:(import $fullname.$e)) for e in exp]
    return nothing
end

end
