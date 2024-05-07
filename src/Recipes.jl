
@recipe(Ziggurat, values) do scene
    Attributes(bins = 15, # Int or iterable of edges
               normalization = :none,
               weights = automatic,
               cycle = [:color => :patchcolor],
               color = theme(scene, :patchcolor),
               fillcolor = automatic,
               fillstrokewidth = 0.0,
               offset = 0.0,
               fillto = automatic,
               scale_to = nothing,
               bar_labels = nothing,
               flip_labels_at = Inf,
               label_color = theme(scene, :textcolor),
               over_background_color = automatic,
               over_bar_color = automatic,
               label_offset = 5,
               label_font = theme(scene, :font),
               label_size = 20,
               label_formatter = bar_label_formatter,
               linestyle = :solid,
               fillalpha = 0.2,
               filternan = true)
end

function Makie.plot!(plot::Ziggurat)
    fillcolor = lift(plot.attributes[:fillcolor], plot.attributes[:color],
                     plot.attributes[:fillalpha]) do x, y, a
        x = x == automatic ? y : x
        isnothing(a) ? x : (x, a)
    end
    values = lift(plot.attributes[:filternan], plot.values) do filternan, v
        filternan ? filter(!isnan, v) : v
    end
    hist!(plot, values; plot.attributes..., color = fillcolor,
          strokewidth = plot.attributes[:fillstrokewidth])
    stephist!(plot, values; plot.attributes...)
    plot
end

@recipe(Hill, values) do scene
    Attributes(color = theme(scene, :patchcolor),
               colormap = theme(scene, :colormap),
               colorscale = identity,
               colorrange = Makie.automatic,
               strokecolor = automatic,
               strokewidth = theme(scene, :linewidth),
               linestyle = nothing,
               strokearound = false,
               npoints = 200,
               offset = 0.0,
               direction = :x,
               boundary = automatic,
               bandwidth = automatic,
               weights = automatic,
               cycle = [:color => :patchcolor],
               inspectable = theme(scene, :inspectable),
               fillalpha = 0.2,
               filternan = true)
end

function Makie.plot!(plot::Hill)
    strokecolor = lift(plot.attributes[:strokecolor], plot.attributes[:color]) do x, y
        x == automatic ? y : x
    end
    fillcolor = lift(plot.attributes[:color],
                     plot.attributes[:fillalpha]) do x, a
        isnothing(a) ? x : (x, a)
    end
    values = lift(plot.attributes[:filternan], plot.values) do filternan, v
        filternan ? filter(!isnan, v) : v
    end
    density!(plot, values; plot.attributes..., color = fillcolor,
             strokecolor)
    plot
end

@recipe(Kinetic, x, y) do scene
    Attributes(color = theme(scene, :color),
               colormap = theme(scene, :colormap),
               colorscale = identity,
               colorrange = Makie.automatic,
               linestyle = nothing,
               cycle = [:color],
               inspectable = theme(scene, :inspectable),
               linewidth = :curv,
               linewidthscale = 1)
end

function Makie.plot!(p::Kinetic)
    x = p.x
    y = p.y
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

    linewidth = lift(p.attributes[:linewidth], x, y) do l, x, y
        if l isa Number
            l = fill(l, length(x))
        elseif l === :x
            l = minter(x)
        elseif l === :y
            l = minter(y)
        elseif l === :curv
            l = difter(y)
        else
            l
        end
    end
    x = lift(interleave, x)
    y = lift(interleave, y)
    linewidth = lift(linewidth) do linewidth
        linewidth = [[l, l] for l in linewidth]
        linewidth = vcat(linewidth...)
    end
    linewidth = lift((x, y) -> x .* y, linewidth, p.attributes[:linewidthscale])
    linesegments!(p, x, y; p.attributes, linewidth)
    # scatter!(p, x, y; p.attributes, markersize =linewidth)
end
