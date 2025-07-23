using Makie
import Makie: @Block, inherit, Text, Observables, GeometryBasics, alpha, red, green, blue,
              GridLayoutBase, automatic, bar_label_formatter, _hist_center_weights, Polygon,
              KernelDensity, Distributions, Statistics.mean, Statistics.quantile,
              KernelDensity.kde
import Makie.StatsBase

function pick_polarhist_edges(vals, bins)
    if bins isa Int
        return range(-1.0π, 1.0π, length = bins)
    else
        if !issorted(bins)
            error("Histogram bins are not sorted: $bins")
        end
        return bins
    end
end

function hist_center_weights(values, edges, normalization, scale_to, wgts)
    w = wgts === automatic ? () : (StatsBase.weights(wgts),)
    h = StatsBase.fit(StatsBase.Histogram, values, w..., edges)
    h_norm = StatsBase.normalize(h; mode = normalization)
    weights = h_norm.weights
    centers = edges[1:(end - 1)] .+ (diff(edges) ./ 2)
    if scale_to === :flip
        weights .= -weights
    elseif !isnothing(scale_to)
        max = maximum(weights)
        weights .= weights ./ max .* scale_to
    end
    return centers, weights
end

@recipe PolarHist (x,) begin
    bins = 15
    normalization = :none
    scale_to = nothing
    weights = automatic
    bar_labels = nothing
    get_drop_attrs(Poly, [])...
end
function Makie.plot!(plot::PolarHist{<:Tuple{AbstractVector{<:Real}}})
    map!(plot.attributes, [:x, :bins, :normalization, :scale_to, :weights],
         [:edges, :widths, :points]) do x, bins, normalization, scale_to, weights
        values = mod.(x .+ π, 2 * π) .- π
        edges = pick_polarhist_edges(values, bins)
        centers, weights = hist_center_weights(values, edges, normalization, scale_to,
                                               weights)
        return edges, diff(edges), Point2f.(centers, weights)
    end
    map!(plot.attributes, [:color, :points], :real_color) do color, points
        Makie.to_color(color === :values ? last.(points) : color)
    end
    map!(plot.attributes, [:bar_labels], :real_bar_labels) do bar_labels
        bar_labels === :values ? :y : bar_labels
    end
    map!(plot.attributes, [:edges, :points], :polygons) do edges, points
        θs = [edges[i]:0.01:edges[i + 1] for i in 1:(length(edges) - 1)]
        rs = [fill(last(points[i]), length(θ)) for (i, θ) in enumerate(θs)]
        polygons = [Polygon(Point2f.(zip([θ..., 0], [r..., 0]))) for (r, θ) in zip(rs, θs)]
        return polygons
    end

    poly!(plot, plot.attributes, plot.polygons)
    plot
end
Makie.preferred_axis_type(plot::PolarHist) = Makie.PolarAxis

# ? ----------------------------- Polar density ---------------------------- ? #
function default_bandwidth_circular(data, alpha::Float64 = 0.09)
    ndata = length(data)
    ndata <= 1 && return alpha

    # Calculate width using variance and IQR
    var_width = sqrt.(2 * (1 - abs.(mean(exp.(im .* data))))) # Batschelet, 1981, no log
    q25, q75 = quantile(data, [0.25, 0.75])
    quantile_width = (q75 - q25) / 1.34
    width = min(var_width, quantile_width)
    if width == 0.0
        if var_width == 0.0
            width = 1.0
        else
            width = var_width
        end
    end
    return alpha * width * ndata^(-0.2)
end

@recipe PolarDensity (x,) begin
    bandwidth = default_bandwidth_circular
    color = :density
    strokecolormap = :viridis
    strokecolor = @inherit color
    strokewidth = @inherit linewidth

    get_drop_attrs(Band, [:color, :strokecolormap])...
    get_drop_attrs(Lines, [attribute_names(Band)..., :linewidth])...
end

function polarkde(vals; bandwidth = default_bandwidth_circular(vals), kwargs...)
    bandwidth isa Function && (bandwidth = bandwidth(vals))
    minimum(vals) <= -π || maximum(vals) > π && error("Values must be in the range (-π, π)")
    dist = Distributions.VonMises(1 / bandwidth)
    boundary = (-π, π)
    p = kde(vals, dist; boundary, kwargs...)
    return p
end

function _color(C, color, xs, ps)
    C = cgrad(C)
    nm = xs -> (xs .- minimum(xs)) ./ (maximum(xs) - minimum(xs))
    if color === :phase || color === :angle
        return C[nm(xs)]
    elseif color === :density
        return C[nm(ps)]
    elseif color isa Vector
        return C[nm(color)]
    elseif color isa Tuple && isnothing(first(color))
        return :transparent
    elseif isnothing(color)
        return :transparent
    else
        return color
    end
end

function Makie.plot!(plot::PolarDensity{<:Tuple{AbstractVector{<:Real}}}) # Set PolarAxis(; theta_as_x=false)
    map!(plot.attributes, [:x, :bandwidth], [:xs, :zs, :ps, :points]) do x, b
        pdf = polarkde(x; bandwidth = b)
        xs = getfield(pdf, :x) |> collect
        ps = getfield(pdf, :density) |> collect
        push!(xs, first(xs)) # close the shape
        zs = zeros(length(xs))
        push!(ps, first(ps)) # close the shape
        points = Point2f[zip(xs, ps)...]
        return xs, zs, ps, points
    end

    map!(plot.attributes, [:color, :strokecolor, :colormap, :strokecolormap, :xs, :ps],
         [:real_color, :real_strokecolor]) do color, strokecolor, colormap, strokecolormap,
                                              xs, ps
        real_color = _color(colormap, color, xs, ps)
        real_strokecolor = _color(strokecolormap, strokecolor, xs, ps)
        return real_color, real_strokecolor
    end
    band!(plot, plot.attributes, plot.xs, plot.zs, plot.ps; color = plot.real_color,
          colormap = plot.colormap)
    lines!(plot, plot.attributes, plot.points; color = plot.real_strokecolor,
           colormap = plot.strokecolormap, linewidth = plot.strokewidth)
    plot
end
Makie.preferred_axis_type(plot::PolarDensity) = Makie.PolarAxis
