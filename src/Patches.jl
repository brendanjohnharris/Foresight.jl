module Patches
# * Patch draworder of bars in violin and boxplots
__precompile__(false)
using Makie
import Makie: plot!, compute_x_and_width, StructArray, StructArrays, automatic,
              KernelDensity, getuniquevalue, median, extrema_nan, RGBA, Polygon,
              PolyElements, poly_convert, to_lines, flip_xy, Mesh, Vec3f, Point2f,
              linesegments!, poly!, to_color, lift, searchsortedfirst, searchsortedlast,
              findfirst, map, isnan, lines!, translate!, Violin

function plot!(plot::Violin)
    x, y = plot[1], plot[2]
    args = @extract plot (width, side, scale, color, show_median, npoints, boundary,
                          bandwidth, weights,
                          datalimits, max_density, dodge, n_dodge, gap, dodge_gap,
                          orientation)
    signals = lift(plot, x, y,
                   args...) do x, y, width, vside, scale_type, color, show_median, n, bound,
                               bw, w, limits, max_density,
                               dodge, n_dodge, gap, dodge_gap, orientation
        x̂, violinwidth = compute_x_and_width(x, width, gap, dodge, n_dodge, dodge_gap)

        # for horizontal violin just flip all componentes
        point_func = Point2f
        if orientation === :horizontal
            point_func = flip_xy ∘ point_func
        end

        # Allow `side` to be either scalar or vector
        sides = broadcast(x̂, vside) do _, s
            return s === :left ? -1 : s === :right ? 1 : 0
        end

        sa = StructArray((x = x̂, side = sides))

        specs = map(StructArrays.finduniquesorted(sa)) do (key, idxs)
            v = view(y, idxs)
            k = KernelDensity.kde(v;
                                  npoints = n,
                                  (bound === automatic ? NamedTuple() : (boundary = bound,))...,
                                  (bw === automatic ? NamedTuple() : (bandwidth = bw,))...,
                                  (w === automatic ? NamedTuple() :
                                   (weights = StatsBase.weights(view(w, idxs)),))...)
            l1, l2 = limits isa Function ? limits(v) : limits
            i1, i2 = searchsortedfirst(k.x, l1), searchsortedlast(k.x, l2)
            kde = (x = view(k.x, i1:i2), density = view(k.density, i1:i2))
            c = getuniquevalue(color, idxs)
            return (x = key.x, side = key.side, color = to_color(c), kde = kde,
                    median = median(v), amount = length(idxs))
        end

        (scale_type ∈ [:area, :count, :width]) || error("Invalid scale type: $(scale_type)")

        max = if max_density === automatic
            maximum(specs) do spec
                if scale_type === :area
                    return extrema_nan(spec.kde.density) |> last
                elseif scale_type === :count
                    return extrema_nan(spec.kde.density .* spec.amount) |> last
                elseif scale_type === :width
                    return NaN
                end
            end
        else
            max_density
        end

        vertices = Vector{Point2f}[]
        lines = Pair{Point2f, Point2f}[]
        colors = RGBA{Float32}[]

        for spec in specs
            scale = 0.5 * violinwidth
            if scale_type === :area
                scale = scale / max
            elseif scale_type === :count
                scale = scale / max * spec.amount
            elseif scale_type === :width
                scale = scale / (extrema_nan(spec.kde.density) |> last)
            end
            xl = reverse(spec.x .- spec.kde.density .* scale)
            xr = spec.x .+ spec.kde.density .* scale
            yl = reverse(spec.kde.x)
            yr = spec.kde.x

            x_coord, y_coord = if spec.side == -1 # left violin
                [spec.x; xl; spec.x], [yl[1]; yl; yl[end]]
            elseif spec.side == 1 # right violin
                [spec.x; xr; spec.x], [yr[1]; yr; yr[end]]
            else
                [spec.x; xr; spec.x; xl], [yr[1]; yr; yl[1]; yl]
            end
            verts = point_func.(x_coord, y_coord)
            push!(vertices, verts)

            if show_median
                # interpolate median bounds between corresponding points
                xm = spec.median
                ip = findfirst(>(xm), spec.kde.x)
                ym₋, ym₊ = spec.kde.density[ip - 1], spec.kde.density[ip]
                xm₋, xm₊ = spec.kde.x[ip - 1], spec.kde.x[ip]
                ym = (xm * (ym₊ - ym₋) + xm₊ * ym₋ - xm₋ * ym₊) / (xm₊ - xm₋)
                median_left = point_func(spec.side == 1 ? spec.x : spec.x - ym * scale, xm)
                median_right = point_func(spec.side == -1 ? spec.x : spec.x + ym * scale,
                                          xm)
                push!(lines, median_left => median_right)
            end

            push!(colors, spec.color)
        end

        return (vertices = vertices, lines = lines, colors = colors)
    end

    geometries = lift(s -> s.vertices, plot, signals)
    transform_func = plot.transformation.transform_func
    meshes = lift(poly_convert, plot, geometries, transform_func)
    a = mesh!(plot, meshes;
              visible = plot.visible,
              shading = plot.shading,
              color = plot.color,
              colormap = plot.colormap,
              colorscale = plot.colorscale,
              colorrange = plot.colorrange,
              lowclip = plot.lowclip,
              highclip = plot.highclip,
              nan_color = plot.nan_color,
              alpha = plot.alpha,
              overdraw = plot.overdraw,
              fxaa = plot.fxaa,
              transparency = plot.transparency,
              inspectable = plot.inspectable,
              space = plot.space,)

    outline = lift(to_lines, plot, geometries)
    stroke = lift(plot, outline, plot.strokecolor) do outline, sc
        if !(meshes[] isa Mesh) && meshes[] isa AbstractVector &&
           sc isa AbstractVector && length(sc) == length(meshes[])
            idx = 1
            return map(outline) do point
                if isnan(point)
                    idx += 1
                end
                return sc[idx]
            end
        else
            return sc
        end
    end

    linesegments!(plot,
                  lift(s -> s.lines, plot, signals);
                  color = plot[:mediancolor],
                  linewidth = plot[:medianlinewidth],
                  visible = plot[:show_median],
                  inspectable = plot[:inspectable])

    lines!(plot, outline, visible = plot.visible,
           color = stroke, linestyle = plot.linestyle, alpha = plot.alpha,
           colormap = plot.strokecolormap,
           linewidth = plot.strokewidth, space = plot.space,
           overdraw = plot.overdraw, transparency = plot.transparency,
           inspectable = plot.inspectable, depth_shift = -1.0f-5)
end
end
