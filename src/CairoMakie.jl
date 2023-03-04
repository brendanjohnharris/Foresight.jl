using .CairoMakie
using .Gtk

function drawonto(canvas, figure)
    @guarded draw(canvas) do _
        scene = figure.scene
        resize!(scene, Gtk.width(canvas), Gtk.height(canvas))
        config = CairoMakie.ScreenConfig(1.0,1.0,:good,true,true)
        screen = CairoMakie.Screen(scene, config, Gtk.cairo_surface(canvas))
        CairoMakie.cairo_draw(screen, scene)
    end
end

function gtkshow(f; name="CairoMakie", resolution=(1920, 1080), kwargs...)
    canvas = @GtkCanvas()
    window = GtkWindow(canvas, name, resolution...; kwargs...)
    drawonto(canvas, f)
end
export gtkshow

Base.show(io::IO, f::Makie.FigureAxisPlot) = gtkshow(f)
Base.show(io::IO, f::Makie.Figure) = gtkshow(f)
