
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
               fillalpha = 0.2)
end

function Makie.plot!(plot::Ziggurat)
    fillcolor = lift(plot.attributes[:fillcolor], plot.attributes[:color],
                     plot.attributes[:fillalpha]) do x, y, a
        x = x == automatic ? y : x
        isnothing(a) ? x : (x, a)
    end
    hist!(plot, plot.values; plot.attributes..., color = fillcolor,
          strokewidth = plot.attributes[:fillstrokewidth])
    stephist!(plot, plot.values; plot.attributes...)
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
               fillalpha = 0.2)
end

function Makie.plot!(plot::Hill)
    strokecolor = lift(plot.attributes[:strokecolor], plot.attributes[:color]) do x, y
        x == automatic ? y : x
    end
    fillcolor = lift(plot.attributes[:color],
                     plot.attributes[:fillalpha]) do x, a
        isnothing(a) ? x : (x, a)
    end
    density!(plot, plot.values; plot.attributes..., color = fillcolor,
             strokecolor)
    plot
end
