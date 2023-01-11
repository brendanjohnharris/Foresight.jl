using Foresight
using Test
using CairoMakie

@testset "Importall" begin
    @test all(isnothing.(eval.(importall(Foresight))))
    @test_nowarn save("./demo_default.png", demofigure())
end

@testset "Demo figure" begin
    @test_nowarn save("./demo.png", demofigure())

    @test_nowarn Makie.set_theme!(foresight(:dark))
    @test_nowarn save("./demo_dark.png", demofigure())

    @test_nowarn Makie.set_theme!(foresight(:dark, :transparent))
    @test_nowarn save("./demo_transparentdark.png", demofigure())

    @test_nowarn Makie.set_theme!(foresight(; font=:serif))
    @test_nowarn save("./demo_serif.png", demofigure())
end
