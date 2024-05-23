using Makie
import Makie.MakieCore

MakieCore.@recipe(CovEllipse, μ, Σ²) do scene
    Makie.Attributes(color = theme(scene, :patchcolor),
                     strokecolor = theme(scene, :patchstrokecolor),
                     strokewidth = theme(scene, :patchstrokewidth),
                     alpha = 0.8,
                     scale = 2)
end

function Makie.plot!(p::CovEllipse)
    μ, Σ² = p.μ, p.Σ²
    scale = p.attributes[:scale]
    if length(μ[]) != size(Σ²[], 1)
        error("Dimension mismatch between mean and covariance")
    end
    θ = range(0, 2π; length = 1000)
    A = @lift sqrt($(Σ²)) * [cos.(θ)'; sin.(θ)'] .* $scale
    x = @lift [Makie.Point2f($(μ)[1] + a[1], $(μ)[2] + a[2]) for a in eachcol($(A))]
    poly!(p, x; color = p.attributes[:color], strokecolor = p.attributes[:strokecolor],
          strokewidth = p.attributes[:strokewidth],
          alpha = p.attributes[:alpha])
    p
end

# Makie.convert_arguments(p::Type{<:CovEllipse}, Σ²::AbstractMatrix) = Makie.convert_arguments(p, zeros(size(Σ², 1)), Σ²)
