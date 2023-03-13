using Foresight
using Test
using CairoMakie

@testset "Importall" begin
    @test all(isnothing.(eval.(importall(Foresight))))
    @test_nowarn Makie.set_theme!(foresight())
    @test_nowarn save("./demo_default.png", demofigure(), px_per_unit = 5)
end

@testset "Demo figure" begin
    @test_nowarn save("./demo.png", demofigure(), px_per_unit = 5)

    @test_nowarn Makie.set_theme!(foresight(:dark))
    @test_nowarn save("./demo_dark.png", demofigure(), px_per_unit = 5)

    @test_nowarn Makie.set_theme!(foresight(:dark, :transparent))
    @test_nowarn save("./demo_transparentdark.png", demofigure(), px_per_unit = 5)

    @test_nowarn Makie.set_theme!(foresight(:serif))
    @test_nowarn save("./demo_serif.png", demofigure(), px_per_unit = 5)
end
