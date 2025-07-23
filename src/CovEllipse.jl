using Makie

@recipe CovEllipse (μ, Σ²) begin
    "Scale factor for the ellipse size, in units of standard deviation."
    scale = 2
    "Number of vertices to use for the ellipse, or a list of angular vertices"
    vertices = 1000
    get_drop_attrs(Poly, [])...
end

function Makie.plot!(plot::CovEllipse)
    map!(plot.attributes, [:μ, :Σ², :scale, :vertices], :x) do μ, Σ², scale, vertices
        if length(μ) != size(Σ², 1)
            throw(ArgumentError("Dimension mismatch between mean and covariance in CovEllipse"))
        end
        θ = vertices isa Integer ? range(0, 2π; length = vertices) : vertices
        A = sqrt(Σ²) * [cos.(θ)'; sin.(θ)'] .* scale
        x = [Makie.Point2f(μ[1] + a[1], μ[2] + a[2]) for a in eachcol(A)]
        return x
    end

    poly!(plot, plot.attributes, plot.x)
    plot
end

# Makie.convert_arguments(p::Type{<:CovEllipse}, Σ²::AbstractMatrix) = Makie.convert_arguments(p, zeros(size(Σ², 1)), Σ²)
