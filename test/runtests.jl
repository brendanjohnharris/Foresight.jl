using Test
using CairoMakie
using CairoMakie.Makie.PlotUtils
using Statistics
using LinearAlgebra
using Foresight
using CairoMakie.Makie.Distributions

@testset "Polar histogram" begin
    x = [rand(Distributions.VonMises(-3, 10), 100); rand(VonMises(0, 10), 100)]

    f = Figure()
    ax = PolarAxis(f[1, 1])
    polarhist!(ax, x; bins = 100)
    display(f)

    f = Figure()
    ax = PolarAxis(f[1, 1])
    polardensity!(ax, x; strokewidth = 5, strokecolor = :crimson)
    display(f)

    f = Figure()
    ax = PolarAxis(f[1, 1])
    polardensity!(ax, x; bins = 100, strokewidth = 5, strokecolor = :angle)
    display(f)
end

@testset "Importall" begin
    @test all(isnothing.(eval.(importall(Foresight))))
    Makie.set_theme!(foresight())
    save("./demo_default.png", demofigure(), px_per_unit = 5)
end

@testset "Demo figure" begin
    @test_nowarn save("./demo.png", demofigure(), px_per_unit = 5)

    @test_nowarn Makie.set_theme!(foresight(:dark))
    @test_nowarn save("./demo_dark.png", demofigure(), px_per_unit = 5)

    @test_nowarn Makie.set_theme!(foresight(:dark, :transparent))
    @test_nowarn save("./demo_transparentdark.png", demofigure(), px_per_unit = 5)

    Makie.set_theme!(foresight(:serif))
    save("./demo_serif.png", demofigure(), px_per_unit = 5)
end

@testset "Seethrough" begin
    C = sunrise
    transparent_gradient = seethrough(C)
    @test C isa PlotUtils.ContinuousColorGradient
end

@testset "Prism plots" begin
    f = 1:100
    x = randn(1000, 4)
    y = x * [1.0; 0.5; 0.01; 1.5] .+
        randn(1000, 4) *
        [1.0 0.04 0.09 0.4; 0.04 1.0 0.01 0.1; 0.09 0.01 1.0 0.2; 0.4 0.1 0.2 1.0]
    z = [x y]
    Σ² = cov(z; dims = 1)
    # heatmap(Σ²; colormap=:binary)

    H = prism(Σ²)
    f = Figure()
    limits = extrema(Σ²)
    prismplot!(f[1, 1], H; limits)

    # i, _ = Foresight.cluster(eachindex(f), Σ²)
    # p = heatmap(◬[i, i])
    # Colorbar(p.figure[1, 1], p.plot)

end
