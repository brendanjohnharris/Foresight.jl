using Plots
using Colors
import Plots.PlotThemes._themes
const cornflowerblue = colorant"cornflowerblue"; export cornflowerblue
const crimson = colorant"crimson"; export crimson
const cucumber = colorant"#77ab58"; export cucumber
const california = colorant"#EF9901"; export california
const juliapurple = colorant"#9558b2"; export juliapurple
const keppel = colorant"#46AF98"; export keppel
const darkbg = colorant"#282C34"; export darkbg

function torgba(c::RGB, a::Real=1)
    Colors.RGBA(c.r, c.g, c.b, a)
end

fourseas_palette = torgba.([
    cornflowerblue,
    crimson,
    cucumber,
    california,
    juliapurple
], (0.7,))


fourseas = Plots.PlotThemes.PlotTheme(
    foreground_color_text = :black,
    fgguide = :black,
    fglegend = :black,
    legendfontcolor = :black,
    legendtitlefontcolor = :black,
    titlefontcolor = :black,
    linewidth = 2.5,
    palette = fourseas_palette,
    colorgradient = :viridis,
    markerstrokecolor=:white,
    framestyle = :grid,
    grid = true,
    minorgrid = true,
    minorgridalpha = 1.0,
    foreground_color_minor_grid = :gray91,
    foreground_color_grid = :gray88,
    foreground_color_legend = nothing,
    background_color_legend = nothing,
    gridlinewidth = 1.5,
    gridalpha = 1.0,
    titlefontsize = 12,
    tickfontsize = 10,
    legend = nothing,
    legendfontsize = 10,
    legendtitlefontsize = 10,
    fontfamily = "Computer Modern",
    minorticks = 2,
); # Plots.showtheme(:fourseas)
Plots.PlotThemes._themes[:fourseas] = fourseas
function fourseas!()
    Plots.PlotThemes._themes[:fourseas] = fourseas
    theme(:fourseas)
end
export fourseas!


fourseas_dark = NonstationaryProcesses.fourseas.defaults |> deepcopy
fourseas_dark[:foreground_color_text] = :white
fourseas_dark[:foreground_color_subplot] = darkbg
fourseas_dark[:fgguide] = :white
fourseas_dark[:fglegend] = :white
fourseas_dark[:legendfontcolor] = :white
fourseas_dark[:legendtitlefontcolor] = :white
fourseas_dark[:titlefontcolor] = :white
fourseas_dark[:gridlinewidth] = 1.0
fourseas_dark[:foreground_color_minor_grid] = :gray25
fourseas_dark[:foreground_color_grid] = :gray35
fourseas_dark[:bg] = darkbg
fourseas_dark[:bgcolor_inside] = darkbg
fourseas_dark[:fontfamily] = "sans-serif"
Plots.PlotThemes._themes[:fourseas_dark] = fourseas_dark |> Plots.PlotThemes.PlotTheme
function fourseas_dark!()
    Plots.PlotThemes._themes[:fourseas_dark] = fourseas_dark |> Plots.PlotThemes.PlotTheme
    theme(:fourseas_dark)
end
export fourseas_dark!
