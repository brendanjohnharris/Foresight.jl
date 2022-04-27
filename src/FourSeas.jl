module FourSeas

using Makie
using Colors
using Random

# * Some nice colors
const cornflowerblue = colorant"#6495ED"; export cornflowerblue
const crimson = colorant"#DC143C"; export crimson
const cucumber = colorant"#77ab58"; export cucumber
const california = colorant"#EF9901"; export california
#const copper = colorant"#c37940"; export copper
const juliapurple = colorant"#9558b2"; export juliapurple
const keppel = colorant"#46AF98"; export keppel
const darkbg = colorant"#282C34"; export darkbg

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

end
