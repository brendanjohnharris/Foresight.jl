using Test
using TestItems
using TestItemRunner

@run_package_tests

@testsnippet Setup begin
    using CairoMakie
    using CairoMakie.Makie.PlotUtils
    using Statistics
    using LinearAlgebra
    using Foresight
    using CairoMakie.Makie.Distributions
    using LaTeXStrings
end

@testitem "Scientific formatting" setup=[Setup] begin
    x = scientific(1e-3, 1)
    @test x == "1.0 × 10⁻³"
    x = scientific(1e-3, 0)
    @test x == "1 × 10⁻³"
    x = scientific(π, 5)
    @test x == "3.14159"
    x = scientific(-π * 10^-6, 3)
    @test x == "-3.142 × 10⁻⁶"

    x = lscientific(1e-3, 1)
    @test x == "1.0\\times 10^{-3}"
    x = lscientific(1e-3, 0)
    @test x == "1\\times 10^{-3}"
    x = lscientific(π, 5)
    @test x == "3.14159"
    x = lscientific(-π * 10^-6, 3)
    @test x == "-3.142\\times 10^{-6}"

    x = (rand(1000) .- 0.5) .* 10 .|> exp10
    @test_nowarn scientific.(x)
    @test_nowarn lscientific.(x)
    @test_nowarn Lscientific.(x)
end

@testitem "Ziggurat plot" setup=[Setup] begin
    x = randn(1000)
    y = randn(1000) .+ 2
    f = Figure()
    ax = Axis(f[1, 1])
    ziggurat!(ax, x .- 1; normalization = :probability)
    ziggurat!(ax, x; normalization = :probability)
    ziggurat!(ax, y; color = :green, bins = 50, normalization = :pdf, linewidth = 4)
    display(f)
end

@testitem "Hill plot" setup=[Setup] begin
    x = randn(1000)
    y = randn(1000) .+ 2
    f = Figure()
    ax = Axis(f[1, 1])
    hill!(ax, x .- 1)
    hill!(ax, x)
    hill!(ax, y; color = :red, bandwidth = 0.01, strokewidth = 5)
    display(f)
end

@testitem "Kinetic plot" setup=[Setup] begin
    x = range(-4π, 4π, length = 10000)
    y = sinc.(x)
    f = Figure()
    ax = Axis(f[1, 1])
    kinetic!(ax, x, y; linewidthscale = 0.5, linewidth = :curv)
    display(f)
end

@testitem "Bandwidth plot" setup=[Setup] begin
    x = range(-4π, 4π, length = 1000)
    y = sinc.(x)
    f = Figure()
    ax = Axis(f[1, 1])
    bandwidth!(ax, x, y; bandwidth = range(0.0001, 0.1, length = length(x)))

    bandwidth!(ax, x, y .+ 0.25; bandwidth = range(0.5, 0.00, length = length(x)),
               direction = :y, alpha = 0.5)
    display(f)
end

@testitem "Polar histogram" setup=[Setup] begin
    x = [rand(Distributions.VonMises(-3, 10), 10000); rand(VonMises(1, 10), 10000)]

    f = Figure()
    ax = PolarAxis(f[1, 1])
    polarhist!(ax, x; bins = 100, strokewidth = 0)
    hist!(ax, x; bins = 100, strokewidth = 0, color = (:red, 0.1)) # Messed up
    display(f)
end

@testitem "Polar density" setup=[Setup] begin
    x = [rand(Distributions.VonMises(-3, 10), 10000); rand(VonMises(1, 10), 10000)]
    f = Figure()
    ax = PolarAxis(f[1, 1])
    polardensity!(ax, x; strokewidth = 10, strokecolor = :crimson)
    display(f)

    x = randn(1000) .* 2
    f = Figure()
    ax = PolarAxis(f[1, 1])
    polardensity!(ax, x; strokewidth = 5, strokecolor = :angle,
                  strokecolormap = cyclic)
    display(f)
end

@testitem "addlabels!" setup=[Setup] begin
    f = Figure()
    gps = subdivide(f, 2, 2)
    @test_nowarn addlabels!(gps)
    @test_nowarn display(f)

    f = Foresight.demofigure()
    @test_nowarn addlabels!(f)
    @test_nowarn display(f)

    f = Foresight.demofigure()
    @test_nowarn addlabels!(f; dims = 1)
    @test_nowarn display(f)

    f = Foresight.demofigure()
    @test_nowarn addlabels!(f, string.(1:6))
    @test_nowarn display(f)

    f = Foresight.demofigure()
    @test_nowarn addlabels!(f, i -> "[$i]")
    @test_nowarn display(f)
end

@testitem "Demo figure" setup=[Setup] begin
    @test_nowarn Makie.set_theme!(foresight())
    f = Foresight.demofigure()
    addlabels!(f)
    save("./demos/demo.png", f, px_per_unit = 5)

    @test_nowarn Makie.set_theme!(foresight(:dark))
    f = Foresight.demofigure()
    addlabels!(f)
    save("./demos/dark.png", f, px_per_unit = 5)

    @test_nowarn Makie.set_theme!(foresight(:dark, :transparent))
    f = Foresight.demofigure()
    addlabels!(f)
    save("./demos/transparent.png", f, px_per_unit = 5)

    Makie.set_theme!(foresight(:serif))
    f = Foresight.demofigure()
    addlabels!(f)
    save("./demos/serif.png", f, px_per_unit = 5)

    Makie.set_theme!(foresight(:physics))
    f = Foresight.demofigure()
    addlabels!(f)
    save("./demos/physics.png", f, px_per_unit = 5)

    save("./palette.svg", cgrad(first.(Foresight.palette[1]), categorical = true))

    for (name, c) in Foresight.foresight_colormaps
        save("./colormaps/$name.svg", c)
    end
    @test_nowarn freeze!(f)
end

@testitem "Seethrough" setup=[Setup] begin
    C = sunrise
    transparent_gradient = seethrough(C)
    @test transparent_gradient isa PlotUtils.ContinuousColorGradient
    transparent_gradient = @test_nowarn seethrough(C, 0.5, 1.0)
    @test transparent_gradient isa PlotUtils.ContinuousColorGradient
end

@testitem "Prism plots" setup=[Setup] begin
    f = 1:100
    x = randn(1000, 4)
    y = x * [1.0; 0.5; 0.01; 1.5] .+
        randn(1000, 4) *
        [1.0 0.04 0.09 0.4; 0.04 1.0 0.01 0.1; 0.09 0.01 1.0 0.2; 0.4 0.1 0.2 1.0]
    z = [x y]
    Σ² = cov(z; dims = 1)
    # heatmap(Σ²; colormap=:binary)

    @test_nowarn H = prism(Σ²)

    xs = 0:0.001:(π * 1.5)
    ys = [sin.(xs .+ i) for i in 0.1:0.1:(2π)]
    ys = hcat(ys...)
    ys = ys + randn(size(ys)) ./ 10
    Σ² = cov(ys; dims = 1)
    H = prism(Σ²; palette = [cornflowerblue, crimson])

    Makie.set_theme!(foresight())
    f = OnePanel()
    limits = (0, maximum(abs.(Σ²)))
    g, ax = prismplot!(f[1, 1], H; limits, colorbarlabel = "Covariance magnitude")
    axislegend(ax,
               [
                   PolyElement(color = (cornflowerblue, 0.7)),
                   PolyElement(color = (crimson, 0.7))
               ],
               ["PC 1", "PC 2"], position = :lt)
    ax.xlabel = ax.ylabel = "Variable"
    f
    save("./recipes/prism_light.png", f; px_per_unit = 5)

    Makie.set_theme!(foresight(:dark, :transparent))
    f = OnePanel()
    limits = (0, maximum(abs.(Σ²)))
    g, ax = prismplot!(f[1, 1], H; limits, colorbarlabel = "Covariance magnitude")
    axislegend(ax,
               [
                   PolyElement(color = (cornflowerblue, 0.7)),
                   PolyElement(color = (crimson, 0.7))
               ],
               ["PC 1", "PC 2"], position = :lt)
    ax.xlabel = ax.ylabel = "Variable"
    f
    save("./recipes/prism_dark.png", f; px_per_unit = 5)
end

@testitem "covellipse" setup=[Setup] begin
    x = randn(10000)
    y = x .+ 0.5 .* randn(10000)
    xy = hcat(x, y)
    μ = mean(xy, dims = 1)
    Σ² = cov(xy)

    Makie.set_theme!(foresight())
    f = Figure()
    ax = Axis(f[1, 1]; xlabel = "x", ylabel = "y")
    @test_nowarn covellipse!(ax, μ, Σ², color = (cornflowerblue, 0.1),
                             strokecolor = cornflowerblue,
                             strokewidth = 5, scale = 2)
    scatter!(ax, x, y; markersize = 2, color = (cornflowerblue, 0.42))
    save("./recipes/covellipse_light.png", f; px_per_unit = 5)

    Makie.set_theme!(foresight(:dark, :transparent))
    f = Figure()
    ax = Axis(f[1, 1]; xlabel = "x", ylabel = "y")
    @test_nowarn covellipse!(ax, μ, Σ², color = (cornflowerblue, 0.1),
                             strokecolor = cornflowerblue,
                             strokewidth = 5, scale = 2)
    scatter!(ax, x, y; markersize = 2, color = (cornflowerblue, 0.42))
    save("./recipes/covellipse_dark.png", f; px_per_unit = 5)
end

@testitem "Importall" setup=[Setup] begin # Keep this at the end
    @test all(isnothing.(eval.(importall(Foresight))))
    Makie.set_theme!(foresight())
    save("./demos/default.png", demofigure(), px_per_unit = 5)
end
