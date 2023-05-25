# module PlotsExt
using .Plots
using .Colors
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

foresight_palette = torgba.([
    cornflowerblue,
    crimson,
    cucumber,
    california,
    juliapurple
], (0.7,))


defaults = (;
    foreground_color_text = :black,
    fgguide = :black,
    fglegend = :black,
    legendfontcolor = :black,
    legendtitlefontcolor = :black,
    titlefontcolor = :black,
    linewidth = 2.5,
    palette = foresight_palette,
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
); # Plots.showtheme(:foresight)
defaults = Dict(pairs(defaults))
foresight = Plots.PlotThemes.PlotTheme(defaults)
Plots.PlotThemes._themes[:foresight] = foresight
function foresight!()
    Plots.PlotThemes._themes[:foresight] = foresight
    theme(:foresight)
end
export foresight!


foresight_dark = defaults |> deepcopy
foresight_dark[:foreground_color_text] = :white
foresight_dark[:foreground_color_subplot] = darkbg
foresight_dark[:fgguide] = :white
foresight_dark[:fglegend] = :white
foresight_dark[:legendfontcolor] = :white
foresight_dark[:legendtitlefontcolor] = :white
foresight_dark[:titlefontcolor] = :white
foresight_dark[:gridlinewidth] = 1.0
foresight_dark[:foreground_color_minor_grid] = :gray25
foresight_dark[:foreground_color_grid] = :gray35
foresight_dark[:bg] = darkbg
foresight_dark[:bgcolor_inside] = darkbg
foresight_dark[:fontfamily] = "sans-serif"
Plots.PlotThemes._themes[:foresight_dark] = foresight_dark |> Plots.PlotThemes.PlotTheme
function foresight_dark!()
    Plots.PlotThemes._themes[:foresight_dark] = foresight_dark |> Plots.PlotThemes.PlotTheme
    theme(:foresight_dark)
end
export foresight_dark!
# end # module
