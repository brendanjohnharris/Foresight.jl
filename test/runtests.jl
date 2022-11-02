using FourSeas
using Test
using CairoMakie

@testset "Importall" begin
    @test all(isnothing.(eval.(importall(FourSeas))))
    @test_nowarn demofigure()
end

@testset "Demo figure" begin
    @test_nowarn Makie.set_theme!(theme_fourseas(:dark))
    @test_nowarn save("./demo_dark.png", demofigure())

    @test_nowarn Makie.set_theme!(theme_fourseas(:dark, :transparent))
    @test_nowarn save("./demo_transparentdark.png", demofigure())

    @test_nowarn Makie.set_theme!(theme_fourseas(; font=:serif))
    @test_nowarn save("./demo_serif.png", demofigure())
end
