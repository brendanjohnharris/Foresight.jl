# ? Format recipe docstrings
using Makie.DocStringExtensions
import Makie: DocThemer, ATTRIBUTES, DocInstances, INSTANCES

import Makie: mixin_generic_plot_attributes, mixin_colormap_attributes,
              documented_attributes, attribute_names, DocumentedAttributes, automatic

function get_attrs(P::Type{<:Plot})
    # Makie.attribute_default_expressions(P)
    Makie.documented_attributes(P)
end
function drop_attrs(attrs::DocumentedAttributes, keys)
    attrs = deepcopy(attrs)
    map(collect(keys)) do key
        if haskey(attrs.d, key)
            delete!(attrs.d, key)
        end
    end
    return attrs
end
function get_drop_attrs(P::Type{<:Plot}, keys)
    attrs = get_attrs(P)
    return drop_attrs(attrs, keys)
end

"""
    ziggurat(x; kwargs...)

Plots a histogram with a transparent fill.

## Key attributes:
`linecolor` = `automatic`: Sets the color of the step outline.

`color` = `@inherit patchcolor`: Color of the interior fill.

`fillalpha` = `0.5`: Transparency of the interior fill.

`filternan` = `true`: Whether to remove NaN values from the data before plotting.
"""
@recipe Ziggurat (x,) begin
    cycle = :color => :patchcolor

    "Color of the histogram steps"
    linecolor = automatic

    "Color of the histogram fill"
    color = @inherit patchcolor

    "Transparency of the histogram fill"
    fillalpha = 0.5

    "Whether to remove NaN values"
    filternan = true

    get_drop_attrs(Hist, [:cycle, :color, :linecolor])...
    get_drop_attrs(StepHist, attribute_names(Hist))...
    mixin_generic_plot_attributes()...
end

function Makie.plot!(plot::Ziggurat{<:Tuple{AbstractVector{<:Real}}})
    # * Stroke color is the same as fill color if left automatic
    map!(plot.attributes, [:color, :linecolor], :real_linecolor) do color, linecolor
        return Makie.to_color(linecolor === automatic ? color : linecolor)
    end

    map!(plot.attributes, [:x, :filternan], :values) do v, filternan
        filternan ? filter(!isnan, v) : v
    end
    map!(plot.attributes, [:color, :fillalpha], :fillcoloralpha) do c, a
        Makie.to_color(isnothing(a) ? c : (c, a))
    end

    hist!(plot, plot.attributes, plot.x; color = plot.fillcoloralpha)
    stephist!(plot, plot.attributes, plot.x; color = plot.real_linecolor)
    plot
end

"""
    hill(x; kwargs...)

Plots a density with a transparent fill.

## Key attributes:
`color` = `@inherit patchcolor`: Color of the interior fill.

`fillalpha` = `0.5`: Transparency of the interior fill.

`filternan` = `true`: Whether to remove NaN values from the data before plotting.

`strokecolor` = `automatic`: Color of the outline stroke.

`strokewidth` = `1`: Width of the outline stroke.
"""
@recipe Hill (x,) begin
    cycle = :color => :patchcolor

    "Transparency of the fill patch"
    fillalpha = 0.5

    "Whether to remove NaN values"
    filternan = true

    "Color of the density fill"
    color = @inherit patchcolor

    "Color of the density stroke"
    strokecolor = automatic

    strokewidth = @inherit linewidth

    get_drop_attrs(Density, [:cycle, :color, :strokecolor, :strokewidth])...
end

function Makie.plot!(plot::Hill{<:Tuple{AbstractVector{<:Real}}})
    # * Stroke color is the same as fill color if left automatic
    map!(plot.attributes, [:color, :strokecolor], :real_strokecolor) do color, strokecolor
        return Makie.to_color(strokecolor === automatic ? color : strokecolor)
    end

    map!(plot.attributes, [:x, :filternan], :values) do v, filternan
        filternan ? filter(!isnan, v) : v
    end
    map!(plot.attributes, [:color, :fillalpha], :fillcoloralpha) do c, a
        Makie.to_color(isnothing(a) ? c : (c, a))
    end
    density!(plot, plot.attributes, plot.x; color = plot.fillcoloralpha,
             strokecolor = plot.real_strokecolor)
    plot
end

"""
    kinetic(x, y; kwargs...)

Plots a line with a varying width.

## Key attribtues:

`linewidth` = `:curv`:

Sets the algorithm for determining the line width.

- `:curv` - Width is determined by the velocity

- `:x` - Width is determined by the x-coordinate

- `:y` - Width is determined by the y-coordinate

- `<: Number` - Width is set to a constant value

`linewidthscale` = `1`: Scale factor for the line width.
"""
@recipe Kinetic (x, y) begin
    cycle = :color
    color = @inherit linecolor
    linewidth = :curv
    linewidthscale = 1

    get_drop_attrs(Density, [:cycle, :color, :linewidth])...
end

function interleave(x)
    x = [collect(x[i:(i + 1)]) for i in eachindex(x)[1:(end - 1)]]
    # append!.(x, NaN)
    vcat(x...)
end
function minter(x)
    l = map(eachindex(x)) do i
        if i == 1
            x[1]
        else
            mean(x[(i - 1):i])
        end
    end
    l = l .- minimum(l)
    l = l ./ maximum(l)
    l .*= 10
    l .+= 1
    return l[2:end]
end

function difter(x)
    l = map(eachindex(x)) do i
        if i < 2
            x[3] - 2 * x[2] + x[1]
        elseif i > length(x) - 1
            x[end - 2] - 2 * x[end - 1] + x[end]
        else
            x[i + 1] - 2 * x[i] + x[i - 1]
        end
    end
    l = exp.(-abs.(l) .^ 2)
    l = l .- minimum(l)
    l = l ./ maximum(l)
    l .*= 10
    l .+= 1
    return l[2:end]
end

function Makie.plot!(plot::Kinetic{<:Tuple{AbstractVector{<:Real}, AbstractVector{<:Real}}})
    map!(plot.attributes, [:linewidth, :x, :y, :linewidthscale],
         :linewidths) do l, x, y, lscale
        if l isa Number
            l = fill(l, length(x) - 1)
        elseif l === :x
            l = minter(x)
        elseif l === :y
            l = minter(y)
        elseif l === :curv
            l = difter(y)
        end
        [x for x in l for _ in 1:2] .* lscale
    end

    map!(plot.attributes, [:x, :y], :xy) do x, y
        map(Point2f, zip(interleave(x), interleave(y)))
    end

    linesegments!(plot, plot.attributes, plot.xy; linewidth = plot.attributes[:linewidths])
    # Rework this to use bandwidth plot...
end

"""
    bandwidth(x, y; kwargs...)

Plots a band of a certain width about a center line.

## Key attributes:
`bandwidth` = `1`: Vertical width of the band in data space. Can be a vector of `length(x)`.

`direction` = `:x`: The direction of the band, either `:x` or `:y`.
"""
@recipe Bandwidth (x, y) begin
    cycle = :color

    "Vertical width of the band in data space"
    bandwidth = 1
    "The direction of the band"
    direction = :x

    get_drop_attrs(Band, [:cycle, :direction])...
end
function Makie.plot!(plot::Bandwidth{<:Tuple{AbstractVector{<:Real},
                                             AbstractVector{<:Real}}})
    map!(plot.attributes, [:x, :y, :bandwidth, :direction], [:xx, :yl, :yu]) do x, y, l, d
        if d === :y
            x, y = y, x
        end
        if eltype(l) <: Number
            yl = y .- (l / 2)
            yu = y .+ (l / 2)
        else
            yl = y .- (first(l) / 2)
            yu = y .+ (last(l) / 2)
        end
        return x, yl, yu
    end
    band!(plot, plot.attributes, plot.attributes[:xx], plot.attributes[:yl],
          plot.attributes[:yu])
end
