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

"""
    polarhist(x; kwargs...)

Plots a polar histogram of the values in `x`. Attributes are shared with `Makie.Hist` and `Makie.Poly`.
"""
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

"""
    polardensity(x; kwargs...)

Plots a polar density plot of the values in `x`.

## Key attributes:
`bandwidth` = `default_bandwidth_circular(x)`: The bandwidth of the kernel density
estimate.

`strokecolor` = `:density`:

Sets the color of the stroke around the density band. Can be a color, or one of the
following color modes:

* `:density` uses the density values as the color.
* `:angle` or `:phase` uses the angle of the values as the color.
* `:transparent` uses a transparent color.
"""
@recipe PolarDensity (x,) begin
    bandwidth = default_bandwidth_circular
    color = @inherit color
    strokecolor = :density

    strokewidth = @inherit linewidth
    strokecolormap = cyclic
    strokecolorrange = automatic
    strokecolorscale = identity
    strokelowclip = automatic
    strokehighclip = automatic
    strokenan_color = :transparent

    get_drop_attrs(Band, [:color])...
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

"""
Return computed color values based on the colormode.
"""
function _color(colormode, xs, ps)
    # nm = xs -> (xs .- minimum(xs)) ./ (maximum(xs) - minimum(xs))
    if colormode === :phase || colormode === :angle
        return xs
    elseif colormode === :density
        return ps
    elseif colormode isa Tuple && isnothing(first(colormode))
        return :transparent
    elseif isnothing(colormode)
        return :transparent
    else
        return colormode
    end
end

function Makie.plot!(plot::PolarDensity{<:Tuple{AbstractVector{<:Real}}})
    map!(plot.attributes, [:x, :bandwidth], [:xs, :zs, :ps, :points]) do x, b
        pdf = polarkde(x; bandwidth = b)
        xs = getfield(pdf, :x) |> collect
        ps = getfield(pdf, :density) |> collect
        push!(xs, first(xs)) # close the shape
        push!(ps, first(ps)) # close the shape
        zs = zeros(length(xs))
        points = Point2f[zip(xs, ps)...]
        return xs, zs, ps, points
    end

    map!(plot.attributes, [:strokecolor, :xs, :ps],
         [:real_strokecolor]) do strokecolormode, xs, ps
        real_strokecolor = _color(strokecolormode, xs, ps)
        return (real_strokecolor,)
    end

    map!(plot.attributes,
         [:color, :xs, :ps],
         [:real_color]) do colormode, xs, ps
        real_color = _color(colormode, xs, ps)
        # if colormap isa Makie.PlotUtils.ColorGradient
        #     colormap = colormap[0:0.01:1]
        # end
        # colormap = convert(Vector{RGBAf}, collect(colormap))
        # if real_color isa AbstractVector{<:Number}
        #     real_color = Makie.numbers_to_colors(real_color, colormap, colorscale,
        #                                          Vec2(colorrange), lowclip,
        #                                          highclip, Makie.to_color(nan_color),
        #                                          interpolate)
        # end
        # return (real_color,)
        return (real_color,)
    end

    band!(plot, plot.attributes, plot.xs, plot.zs, plot.ps; color = plot.real_color)

    lines!(plot, plot.attributes, plot.points;
           linewidth = plot.strokewidth,
           color = plot.real_strokecolor,
           colormap = plot.strokecolormap,
           colorrange = plot.strokecolorrange,
           colorscale = plot.strokecolorscale,
           lowclip = plot.strokelowclip,
           highclip = plot.strokehighclip,
           nan_color = plot.strokenan_color)
    plot
end
Makie.preferred_axis_type(plot::PolarDensity) = Makie.PolarAxis
