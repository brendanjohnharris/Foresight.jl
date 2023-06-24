const mediumcarmine = colorant"#ad4338ff"
const steelblue = colorant"#3e86acff"
const spanishgrey = colorant"#999999ff"
const raisinblack = colorant"#252525ff"

redblue_order = [mediumcarmine,
    steelblue]

redblue_palette = (
    patchcolor=redblue_order,
    color=redblue_order,
    strokecolor=redblue_order) |> Attributes

grey_order = [raisinblack,
    spanishgrey]

grey_palette = (
    patchcolor=grey_order,
    color=grey_order,
    strokecolor=grey_order) |> Attributes


function _foresight!(thm::Attributes, ::Val{:grey})
    setall!(thm, :xgridvisible, false)
    setall!(thm, :ygridvisible, false)
    setall!(thm, :zgridvisible, false)
    setall!(thm, :leftspinevisible, true)
    setall!(thm, :bottomspinevisible, true)
    setall!(thm, :topspinevisible, false)
    setall!(thm, :rightspinevisible, false)

    setall!(thm, :xminorticksvisible, true)
    setall!(thm, :yminorticksvisible, true)
    setall!(thm, :zminorticksvisible, true)
    setall!(thm, :xticksvisible, true)
    setall!(thm, :yticksvisible, true)
    setall!(thm, :zticksvisible, true)

    setall!(thm, :xspinesvisible, true)
    setall!(thm, :yspinesvisible, true)
    setall!(thm, :zspinesvisible, true)

    setall!(thm, :colormap, :viridis)
    setall!(thm, :spinewidth, 1.5)
    Makie._update_key!(thm, :palette, grey_palette)
end

function _foresight!(thm::Attributes, ::Val{:redblue})
    _foresight!(thm, Val(:grey))
    Makie._update_key!(thm, :palette, redblue_palette)
end



#!!!!!!!!!!!!CHANGE REDBLUE FONT TO SOMETHING MORE COMPATIBLE!!!!!!!!!!!!!
