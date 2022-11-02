palette = (
    patchcolor = [      (cornflowerblue, 0.7),
                        (crimson, 0.7),
                        (cucumber, 0.7),
                        (california, 0.7),
                        (juliapurple, 0.7)],
    color = [           (cornflowerblue, 0.7),
                        (crimson, 0.7),
                        (cucumber, 0.7),
                        (california, 0.7),
                        (juliapurple, 0.7)],
    strokecolor = [     (cornflowerblue, 0.7),
                        (crimson, 0.7),
                        (cucumber, 0.7),
                        (california, 0.7),
                        (juliapurple, 0.7)])



function _theme_fourseas(; globalfont=fourseasfont())
    Theme(;
        colormap = :turbo,
        strokewidth = 10.0,
        strokecolor = :black,
        strokevisible = true,
        font = globalfont,
        palette,
        linewidth = 5.0,
        Axis = (;
            backgroundcolor = :white,
            xgridcolor = :gray88,
            ygridcolor = :gray88,
            xminorgridcolor = :gray91,
            xminorgridvisible = true,
            yminorgridcolor = :gray91,
            yminorgridvisible = true,
            leftspinevisible = false,
            rightspinevisible = false,
            bottomspinevisible = false,
            topspinevisible = false,
            xminorticksvisible = false,
            yminorticksvisible = false,
            xticksvisible = false,
            yticksvisible = false,
            spinewidth = 1,
            xticklabelcolor = :black,
            yticklabelcolor = :black,
            titlecolor = :black,
            xticksize = 4,
            yticksize = 4,
            xtickwidth = 1.5,
            ytickwidth = 1.5,
            xgridwidth = 1.5,
            ygridwidth = 1.5,
            xlabelpadding = 3,
            ylabelpadding = 3,
            palette,
            titlefont = string(globalfont)*" bold", # "times serif bold",
            xticklabelfont = globalfont,
            yticklabelfont = globalfont,
            xlabelfont = globalfont,
            ylabelfont = globalfont,
            titlesize = 20,
        ),
        Legend = (;
            framevisible = false,
            padding = (0, 0, 0, 0),
            patchcolor = :transparent,
            titlefont = string(globalfont)*" Bold",
            labelfont = globalfont,
        ),
        Axis3 = (;
            xgridcolor = :gray81,
            ygridcolor = :gray81,
            zgridcolor = :gray81,
            xspinesvisible = false,
            yspinesvisible = false,
            zspinesvisible = false,
            yzpanelcolor = :white,
            xzpanelcolor = :white,
            xypanelcolor = :white,
            xticksvisible = false,
            yticksvisible = false,
            zticksvisible = false,
            titlefont = string(globalfont)*" Bold",
            xticklabelfont = globalfont,
            yticklabelfont = globalfont,
            zticklabelfont = globalfont,
            xlabelfont = globalfont,
            ylabelfont = globalfont,
            zlabelfont = globalfont,
            titlesize = 20,
            palette
        ),
        Colorbar = (;
            tickcolor = :white,
            tickalign = 1,
            ticklabelcolor = :black,
            spinewidth = 0,
            ticklabelpad = 5,
            ticklabelfont = globalfont,
            labelfont = globalfont,
        ),
        Textbox = (;
            font = globalfont,
        )
    )
end
四海 = theme_fourseas
export theme_fourseas



# # * A nicer looking histogram
# @recipe(Histogram, x) do scene
#     Theme(
#         color => :red, # Why is this so hard
#         # strokewidth => 5,
#     )
# end
# argument_names(::Type{<:Histogram}) = (:x,)
# function Makie.plot!(histogram::Histogram)
#     hist!(histogram, histogram[:x]; normalization=:density)
#     density!(histogram, histogram[:x]; color=RGBA(0, 0, 0, 0))
#     histogram
# end



function theme_fourseas(options...; font=fourseasfont())
    if :serif ∈ options
        thm = _theme_fourseas(globalfont=:CMU)
    else
        thm = _theme_fourseas(globalfont=font)
    end
    options = collect(options)
    options = options[options .!= :serif]
    _theme_fourseas!.((thm,), Val.(options))
    return thm
end


function setall!(thm::Attributes, attribute, value)
    thm[attribute] = value
    for a in keys(thm)
        if thm[a] isa Attributes
            thm[a][attribute] = value
        end
    end
end

transparent = Makie.RGBA(0, 0, 0, 0)
function _theme_fourseas!(thm::Attributes, ::Val{:transparent})
    setall!(thm, :backgroundcolor, transparent)
    setall!(thm, :yzpanelcolor, transparent)
    setall!(thm, :xzpanelcolor, transparent)
    setall!(thm, :xypanelcolor, transparent)
end
function _theme_fourseas!(thm::Attributes, ::Val{:dark})
    gridcolor = :gray38
    minorgridcolor = :gray51
    strokecolor = textcolor = :white
    setall!(thm, :strokecolor, strokecolor)
    setall!(thm, :backgroundcolor, darkbg)
    setall!(thm, :textcolor, textcolor)
    setall!(thm, :xgridcolor, gridcolor)
    setall!(thm, :ygridcolor, gridcolor)
    setall!(thm, :zgridcolor, gridcolor)
    setall!(thm, :xminorgridcolor, minorgridcolor)
    setall!(thm, :yminorgridcolor, minorgridcolor)
    setall!(thm, :zminorgridcolor, minorgridcolor)
    setall!(thm, :xticklabelcolor, textcolor)
    setall!(thm, :yticklabelcolor, textcolor)
    setall!(thm, :zticklabelcolor, textcolor)
    setall!(thm, :titlecolor, textcolor)
    setall!(thm, :yzpanelcolor, darkbg)
    setall!(thm, :xzpanelcolor, darkbg)
    setall!(thm, :xypanelcolor, darkbg)
    setall!(thm, :tickcolor, textcolor)
    setall!(thm, :ticklabelcolor, textcolor)
    thm[:Axis3][:xspinesvisible] = false
    thm[:Axis3][:yspinesvisible] = false
    thm[:Axis3][:zspinesvisible] = false
    thm[:Axis3][:xticksvisible] = false
    thm[:Axis3][:yticksvisible] = false
    thm[:Axis3][:zticksvisible] = false
end
