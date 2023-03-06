using .CairoMakie
using .Gtk

function drawonto(canvas, scene::CairoMakie.Scene)
    @guarded draw(canvas) do _
        resize!(scene, Gtk.width(canvas), Gtk.height(canvas))
        config = CairoMakie.ScreenConfig(1.0,1.0,:good,true,true)
        screen = CairoMakie.Screen(scene, config, Gtk.cairo_surface(canvas))
        CairoMakie.cairo_draw(screen, scene)
    end
end

function gtkshow(scene::CairoMakie.Scene; name="CairoMakie", resolution=(1920, 1080), kwargs...)
    canvas = @GtkCanvas()
    window = GtkWindow(canvas, name, resolution...; kwargs...)
    drawonto(canvas, scene)
    show(canvas)
end
gtkshow(f::CairoMakie.Figure; kwargs...) = gtkshow(f.scene; kwargs...)
gtkshow(f::CairoMakie.Makie.FigureAxisPlot; kwargs...) = gtkshow(f.figure; kwargs...)
export gtkshow

Base.show(io::IO, f::CairoMakie.Makie.FigureAxisPlot) = gtkshow(f)
Base.show(io::IO, f::CairoMakie.Figure) = gtkshow(f)
Base.show(io::IO, f::CairoMakie.Scene) = gtkshow(f)
Base.display(f::CairoMakie.Makie.FigureAxisPlot) = gtkshow(f)
Base.display(f::CairoMakie.Figure) = gtkshow(f)
Base.display(f::CairoMakie.Scene) = gtkshow(f)
