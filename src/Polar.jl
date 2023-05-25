# module Polar
using Makie
import Makie: @Block, inherit, Text, Observables, GeometryBasics, alpha, red, green, blue, GridLayoutBase, automatic, bar_label_formatter, _hist_center_weights, Polygon

# ! implementing https://github.com/MakieOrg/Makie.jl/pull/2014

inherit(scene, attr::NTuple{1, <: Symbol}, default_value) = inherit(scene, attr[begin], default_value)


function inherit(scene, attr::NTuple{N, <: Symbol}, default_value) where N
    current_dict = scene.theme
    for i in 1:(N-1)
        if haskey(current_dict, attr[i])
            current_dict = current_dict[attr[i]]
        else
            break
        end
    end

    if haskey(current_dict, attr[N])
        return lift(identity, current_dict[attr[N]])
    else
        return inherit(scene.parent, attr, default_value)
    end
end

function inherit(::Nothing, attr::NTuple{N, Symbol}, default_value::T) where {N, T}
    default_value
end


@Block PolarAxis begin
    scene::Scene
    @attributes begin
        "The height setting of the scene."
        height = nothing
        "The width setting of the scene."
        width = nothing
        "Controls if the parent layout can adjust to this element's width"
        tellwidth = true
        "Controls if the parent layout can adjust to this element's height"
        tellheight = true
        "The horizontal alignment of the scene in its suggested bounding box."
        halign = :center
        "The vertical alignment of the scene in its suggested bounding box."
        valign = :center
        "The alignment of the scene in its suggested bounding box."
        alignmode = Inside()
        "The numerical limits from center circle to outer radius"
        limits::Tuple{Float32, Float32} = (0.0, 10.0)
        "The direction of rotation.  Can be -1 (clockwise) or 1 (counterclockwise)."
        direction = 1
        "The initial angle offset.  This essentially rotates the axis."
        θ_0 = 0f0
        "The width of the spine."
        spinewidth = 2
        "The color of the spine."
        spinecolor = :black
        "Controls whether the spine is visible."
        spinevisible = true
        "The linestyle of the spine."
        spinestyle = nothing
        "The specifier for the radial (`r`) ticks, similar to `xticks` for a normal Axis."
        rticks = LinearTicks(4)
        "The specifier for the minor `r` ticks."
        rminorticks = IntervalsBetween(2)
        "The color of the `r` grid."
        rgridcolor = inherit(scene, (:Axis, :ygridcolor), (:black, 0.5))
        "The linewidth of the `r` grid."
        rgridwidth = inherit(scene, (:Axis, :ygridwidth), 1)
        "The linestyle of the `r` grid."
        rgridstyle = inherit(scene, (:Axis, :ygridstyle), nothing)
        "Controls if the `r` grid is visible."
        rgridvisible = inherit(scene, (:Axis, :ygridvisible), true)
        "The formatter for the `r` ticks"
        rtickformat = Makie.automatic
        "The fontsize of the `r` tick labels."
        rticklabelsize = inherit(scene, (:Axis, :yticklabelsize), 16)
        "The font of the `r` tick labels."
        rticklabelfont = inherit(scene, (:Axis, :yticklabelfont), inherit(scene, :font, Makie.defaultfont()))
        "The color of the `r` tick labels."
        rticklabelcolor = inherit(scene, (:Axis, :yticklabelcolor), inherit(scene, :textcolor, :black))
        "Controls if the `r` ticks are visible."
        rticklabelsvisible = inherit(scene, (:Axis, :yticklabelsvisible), true)
        "The angle in radians along which the `r` ticks are printed."
        rtickangle = π/8
        "The specifier for the angular (`θ`) ticks, similar to `yticks` for a normal Axis."
        θticks = MultiplesTicks(12, π, "π")
        "The specifier for the minor `θ` ticks."
        θminorticks = IntervalsBetween(2)
        "The color of the `θ` grid."
        θgridcolor = inherit(scene, (:Axis, :xgridcolor), (:black, 0.5))
        "The linewidth of the `θ` grid."
        θgridwidth = inherit(scene, (:Axis, :xgridwidth), 1)
        "The linestyle of the `θ` grid."
        θgridstyle = inherit(scene, (:Axis, :xgridstyle), nothing)
        "Controls if the `θ` grid is visible."
        θgridvisible = inherit(scene, (:Axis, :xgridvisible), true)
        "The formatter for the `θ` ticks."
        θtickformat = Makie.automatic
        "The fontsize of the `θ` tick labels."
        θticklabelsize = inherit(scene, (:Axis, :xticklabelsize), 16)
        "The font of the `θ` tick labels."
        θticklabelfont = inherit(scene, (:Axis, :xticklabelfont), inherit(scene, :font, Makie.defaultfont()))
        "The color of the `θ` tick labels."
        θticklabelcolor = inherit(scene, (:Axis, :xticklabelcolor), inherit(scene, :textcolor, :black))
        "Controls if the `θ` ticks are visible."
        θticklabelsvisible = inherit(scene, (:Axis, :xticklabelsvisible), true)
        "The title of the plot"
        title = " "
        "The gap between the title and the top of the axis"
        titlegap = inherit(scene, (:Axis, :titlesize), inherit(scene, :fontsize, 16)[] / 2)
        "The alignment of the title.  Can be any of `:center`, `:left`, or `:right`."
        titlealign = :center
        "The fontsize of the title."
        titlesize = inherit(scene, (:Axis, :titlesize), inherit(scene, :fontsize, 16)[] * 1.2)
        "The font of the title."
        titlefont = inherit(scene, (:Axis, :titlefont), inherit(scene, :font, Makie.defaultfont()))
        "The color of the title."
        titlecolor = inherit(scene, (:Axis, :titlecolor), inherit(scene, :textcolor, :black))
        "Controls if the title is visible."
        titlevisible = inherit(scene, (:Axis, :titlevisible), true)
        "The color of the `r` minor grid."
        rminorgridcolor = inherit(scene, (:Axis, :yminorgridcolor), (:black, 0.2))
        "The linewidth of the `r` minor grid."
        rminorgridwidth = inherit(scene, (:Axis, :yminorgridwidth), 1)
        "The linestyle of the `r` minor grid."
        rminorgridstyle = inherit(scene, (:Axis, :yminorgridstyle), nothing)
        "Controls if the `r` minor grid is visible."
        rminorgridvisible = inherit(scene, (:Axis, :yminorgridvisible), true)
        "The color of the `θ` minor grid."
        θminorgridcolor = inherit(scene, (:Axis, :xminorgridcolor), (:black, 0.2))
        "The linewidth of the `θ` minor grid."
        θminorgridwidth = inherit(scene, (:Axis, :xminorgridwidth), 1)
        "The linestyle of the `θ` minor grid."
        θminorgridstyle = inherit(scene, (:Axis, :xminorgridstyle), nothing)
        "Controls if the `θ` minor grid is visible."
        θminorgridvisible = inherit(scene, (:Axis, :xminorgridvisible), true)
        "The density at which grid lines are sampled."
        sample_density = 100
        "Controls whether to activate the nonlinear clip feature.  Note that this should not be used when the background is ultimately transparent."
        clip = true
    end
end


# First, define the polar-to-cartesian transformation as a Makie transformation
# which is fully compliant with the interface

"""
    PolarAxisTransformation(θ_0::Float64, direction::Int)

This struct defines a general polar-to-cartesian transformation, i.e.,
```math
(r, θ) -> (r \\cos(direction * (θ + θ_0)), r \\sin(direction * (θ + θ_0)))
```

where θ is assumed to be in radians.

`direction` should be either -1 or +1, and `θ_0` may be any value.
"""
struct PolarAxisTransformation
    θ_0::Float64
    direction::Int
end

Base.broadcastable(x::PolarAxisTransformation) = (x,)

function Makie.apply_transform(trans::PolarAxisTransformation, point::VecTypes{2, T}) where T <: Real
    y, x = point[1] .* sincos((point[2] + trans.θ_0) * trans.direction)
    return Point2f(x, y)
end

function Makie.apply_transform(f::PolarAxisTransformation, point::VecTypes{N2, T}) where {N2, T}
    p_dim = to_ndim(Point2f, point, 0.0)
    p_trans = Makie.apply_transform(f, p_dim)
    if 2 < N2
        p_large = ntuple(i-> i <= 2 ? p_trans[i] : point[i], N2)
        return Point{N2, Float32}(p_large)
    else
        return to_ndim(Point{N2, Float32}, p_trans, 0.0)
    end
end

# Define a method to transform boxes from input space to transformed space
function Makie.apply_transform(f::PolarAxisTransformation, r::Rect2{T}) where {T}
    # TODO: once Proj4.jl is updated to PROJ 8.2, we can use
    # proj_trans_bounds (https://proj.org/development/reference/functions.html#c.proj_trans_bounds)
    N = 21
    umin = vmin = T(Inf)
    umax = vmax = T(-Inf)
    xmin, ymin = minimum(r)
    xmax, ymax = maximum(r)
    # If ymax is 2π away from ymin, then the limits
    # are a circle, meaning that we only need the max radius
    # which is trivial to find.
    # @show r
    if abs(ymax - ymin) ≈ 2π
        @assert xmin ≥ 0
        rmax = xmax
        # the diagonal of a square is sqrt(2) * side
        # the radius of a circle inscribed within that square is side/2
        mins = Point2f(-rmax) #Makie.apply_transform(f, Point2f(xmin, ymin))
        maxs = Point2f(rmax*2) #Makie.apply_transform(f, Point2f(xmax - xmin, prevfloat(2f0π)))
        # @show(mins, maxs)
        return Rect2f(mins,maxs)
    end
    for x in range(xmin, xmax; length = N)
        for y in range(ymin, ymax; length = N)
            u, v = Makie.apply_transform(f, Point(x, y))
            umin = min(umin, u)
            umax = max(umax, u)
            vmin = min(vmin, v)
            vmax = max(vmax, v)
        end
    end

    return Rect(Vec2(umin, vmin), Vec2(umax-umin, vmax-vmin))
end


# Define its inverse (for interactivity)
Makie.inverse_transform(trans::PolarAxisTransformation) = Makie.PointTrans{2}() do point
    Point2f(hypot(point[1], point[2]), -trans.direction * (atan(point[2], point[1]) - trans.θ_0))
end

# End transform code

# Some useful code to transform from data (transformed) space to pixelspace

function project_to_pixelspace(scene, point::VecTypes{N, T}) where {N, T}
    @assert N ≤ 3
    return to_ndim(
        typeof(point),
        Makie.project(
            # obtain the camera of the Scene which will project to its screenspace
            camera(scene),
            # go from dataspace (transformation applied to inputspace) to pixelspace
            :data, :pixel,
            # apply the transform to go from inputspace to dataspace
            Makie.apply_transform(
                scene.transformation.transform_func[],
                point
            )
        ),
        0.0
    )
end

function project_to_pixelspace(scene, points::AbstractVector{Point{N, T}}) where {N, T}
    to_ndim.(
        (eltype(points),),
        Makie.project.(
            # obtain the camera of the Scene which will project to its screenspace
            (Makie.camera(scene),),
            # go from dataspace (transformation applied to inputspace) to pixelspace
            (:data,), (:pixel,),
            # apply the transform to go from inputspace to dataspace
            Makie.apply_transform(
                scene.transformation.transform_func[],
                points
            )
        ),
        (0.0,)
    )
end

# A function which redoes text layouting, to provide a bbox for arbitrary text.

function text_bbox(textstring::AbstractString, fontsize::Union{AbstractVector, Number}, font, align, rotation, justification, lineheight, word_wrap_width = -1)
    glyph_collection = Makie.layout_text(
            textstring, fontsize,
            string(font), [], align, rotation, justification, lineheight,
            RGBAf(0,0,0,0), RGBAf(0,0,0,0), 0f0, word_wrap_width
        )

    return Rect2f(Makie.boundingbox(glyph_collection, Point3f(0), Makie.to_rotation(rotation)))
end

function text_bbox(plot::Text)
    return text_bbox(
        plot.text[],
        plot.fontsize[],
        plot.font[],
        plot.align[],
        plot.rotation[],
        plot.justification[],
        plot.lineheight[],
        RGBAf(0,0,0,0), RGBAf(0,0,0,0), 0f0,
        plot.word_wrap_width[]
    )
end

Makie.can_be_current_axis(ax::PolarAxis) = true

function Makie.initialize_block!(po::PolarAxis)
    cb = po.layoutobservables.computedbbox

    square = lift(cb) do cb
        # find the widths of the computed bbox
        ws = widths(cb)
        # get the minimum width
        min_w = minimum(ws)
        # the scene must be a square, so the width must be the same
        new_ws = Vec2f(min_w, min_w)
        # center the scene
        diff = new_ws - ws
        new_o = cb.origin - 0.5diff
        new_o =
        Rect(round.(Int, new_o), round.(Int, new_ws))
    end

    scene = Scene(po.blockscene, square, camera = cam2d!, backgroundcolor = :transparent)

    translate!(scene, 0, 0, -100)

    Observables.connect!(
        scene.transformation.transform_func,
        @lift(PolarAxisTransformation($(po.θ_0), $(po.direction)))
    )

    notify(po.limits)


    # Whenever the limits change or the scene is resized,
    # update the camera.
    onany(po.limits, scene.px_area) do lims, px_area
        adjustcam!(po, lims, (-1.0π, 1.0π))
    end


    po.scene = scene

    # Outsource to `draw_axis` function
    (spineplot, rgridplot, θgridplot, rminorgridplot, θminorgridplot, rticklabelplot, θticklabelplot) = draw_axis!(po)

    # Handle protrusions

    θticklabelprotrusions = Observable(GridLayoutBase.RectSides(
        0f0,0f0,0f0,0f0
        )
    )

    old_input = Ref(θticklabelplot[1][])
    pop!(old_input[])

    onany(θticklabelplot[1]) do input
        # Only if the tick labels have changed, should we recompute the tick label
        # protrusions.
        # This should be changed by removing the call to `first`
        # when the call types are changed to the text, position=positions format
        # introduced in #.
        if length(old_input[]) == length(input) && all(first.(input) .== first.(old_input[]))
            return
        else
            # px_area = pixelarea(scene)[]
            # calculate text boundingboxes individually and select the maximum boundingbox
            text_bboxes = text_bbox.(
                first.(θticklabelplot[1][]),
                Ref(θticklabelplot.fontsize[]),
                θticklabelplot.font[],
                θticklabelplot.align[] isa Tuple ? Ref(θticklabelplot.align[]) : θticklabelplot.align[],
                θticklabelplot.rotation[],
                0.0,
                0.0,
                θticklabelplot.word_wrap_width[]
            )
            maxbox = maximum(widths.(text_bboxes))
            # box = data_limits(θticklabelplot)
            # @show maxbox px_area
            # box = Rect2(
            #     to_ndim(Point2f, project_to_pixelspace(po.blockscene, box.origin), 0),
            #     to_ndim(Point2f, project_to_pixelspace(po.blockscene, box.widths), 0)
            # )
            # @show box
            old_input[] = input


            θticklabelprotrusions[] = GridLayoutBase.RectSides(
                maxbox[1],#max(0, left(box) - left(px_area)),
                maxbox[1],#max(0, right(box) - right(px_area)),
                maxbox[2],#max(0, bottom(box) - bottom(px_area)),
                maxbox[2],#max(0, top(box) - top(px_area))
            )
        end
    end


    notify(θticklabelplot[1])


    # Set up the title position
    title_position = lift(pixelarea(scene), po.titlegap, po.titlealign, θticklabelprotrusions) do area, titlegap, titlealign, θtlprot
        calculate_polar_title_position(area, titlegap, titlealign, θtlprot)
    end

    titleplot = text!(
        po.blockscene,
        title_position;
        text = po.title,
        font = po.titlefont,
        fontsize = po.titlesize,
        color = po.titlecolor,
        align = @lift(($(po.titlealign), :center)),
        visible = po.titlevisible
    )

    # We only need to update the title protrusion calculation when some parameter
    # which affects the glyph collection changes.  But, we don't want to update
    # the protrusion when the position changes.
    title_update_obs = lift((x...) -> true, po.title, po.titlefont, po.titlegap, po.titlealign, po.titlevisible, po.titlesize)
    #
    protrusions = lift(θticklabelprotrusions, title_update_obs) do θtlprot, _
        GridLayoutBase.RectSides(
            θtlprot.left,
            θtlprot.right,
            θtlprot.bottom,
            (title_position[][2] + boundingbox(titleplot).widths[2]/2 - top(pixelarea(scene)[])),
        )
    end

    connect!(po.layoutobservables.protrusions, protrusions)


    # debug statements
    # @show boundingbox(scene) data_limits(scene)
    # Main.@infiltrate
    # display(scene)

    return
end

function draw_axis!(po::PolarAxis)

    rtick_pos_lbl = Observable{Vector{<:Tuple{AbstractString, Point2f}}}()
    θtick_pos_lbl = Observable{Vector{<:Tuple{AbstractString, Point2f}}}()

    rgridpoints = Observable{Vector{Makie.GeometryBasics.LineString}}()
    θgridpoints = Observable{Vector{Makie.GeometryBasics.LineString}}()

    rminorgridpoints = Observable{Vector{Makie.GeometryBasics.LineString}}()
    θminorgridpoints = Observable{Vector{Makie.GeometryBasics.LineString}}()

    spinepoints = Observable{Vector{Point2f}}()

    θlims = (-1.0π, 1.0π)

    onany(po.rticks, po.θticks, po.rminorticks, po.θminorticks, po.rtickformat, po.θtickformat, po.rtickangle, po.limits, po.sample_density, po.scene.px_area, po.scene.transformation.transform_func, po.scene.camera_controls.area) do rticks, θticks, rminorticks, θminorticks, rtickformat, θtickformat, rtickangle, limits, sample_density, pixelarea, trans, area

        rs = LinRange(limits..., sample_density)
        θs = LinRange(θlims..., sample_density)

        _rtickvalues, _rticklabels = Makie.get_ticks(rticks, identity, rtickformat, limits...)
        _θtickvalues, _θticklabels = Makie.get_ticks(θticks, identity, θtickformat, θlims...)

        # Since θ = 0 is at the same position as θ = 2π, we remove the last tick
        # iff the difference between the first and last tick is exactly 2π
        # This is a special case, since it's the only possible instance of colocation
        if (_θtickvalues[end] - _θtickvalues[begin]) == 2π
            pop!(_θtickvalues)
            pop!(_θticklabels)
        end

        θtextbboxes = text_bbox.(
            _θticklabels, (po.θticklabelsize[],), (po.θticklabelfont[],), ((:center, :center),), 0f0, 0f0, 0f0, -1
        )

        rtick_pos_lbl[] = tuple.(_rticklabels, project_to_pixelspace(po.scene, Point2f.(_rtickvalues, rtickangle)) .+ Ref(pixelarea.origin))

        θdiags = map(sqrt ∘ sum ∘ (x -> x .^ 2), widths.(θtextbboxes))

        θgaps = θdiags ./ 2 .* (x -> Vec2f(cos(x), sin(x))).((_θtickvalues .+ trans.θ_0) .* trans.direction)

        θtickpos = project_to_pixelspace(po.scene, Point2f.(limits[end], _θtickvalues)) .+ θgaps .+ Ref(pixelarea.origin)

        _rminortickvalues = Makie.get_minor_tickvalues(rminorticks, identity, _rtickvalues, limits...)
        _θminortickvalues = Makie.get_minor_tickvalues(θminorticks, identity, _θtickvalues, θlims...)

        _rgridpoints = [project_to_pixelspace(po.scene, Point2f.(r, θs)) .+ Ref(pixelarea.origin) for r in _rtickvalues]
        _θgridpoints = [project_to_pixelspace(po.scene, Point2f.(rs, θ)) .+ Ref(pixelarea.origin) for θ in _θtickvalues]

        _rminorgridpoints = [project_to_pixelspace(po.scene, Point2f.(r, θs)) .+ Ref(pixelarea.origin) for r in _rminortickvalues]
        _θminorgridpoints = [project_to_pixelspace(po.scene, Point2f.(rs, θ)) .+ Ref(pixelarea.origin) for θ in _θminortickvalues]

        θtick_pos_lbl[] = tuple.(_θticklabels, θtickpos)

        spinepoints[] = project_to_pixelspace(po.scene, Point2f.(limits[end], θs)) .+ Ref(pixelarea.origin)

        rgridpoints[] = Makie.GeometryBasics.LineString.(_rgridpoints)
        θgridpoints[] = Makie.GeometryBasics.LineString.(_θgridpoints)

        rminorgridpoints[] = Makie.GeometryBasics.LineString.(_rminorgridpoints)
        θminorgridpoints[] = Makie.GeometryBasics.LineString.(_θminorgridpoints)

    end

    # on() do i
    #     adjustcam!(po, po.limits[])
    # end

    notify(po.sample_density)

    # plot using the created observables
    # spine
    spineplot = lines!(
        po.blockscene, spinepoints;
        color = po.spinecolor,
        linestyle = po.spinestyle,
        linewidth = po.spinewidth,
        visible = po.spinevisible
    )
    # major grids
    rgridplot = lines!(
        po.blockscene, rgridpoints;
        color = po.rgridcolor,
        linestyle = po.rgridstyle,
        linewidth = po.rgridwidth,
        visible = po.rgridvisible
    )

    θgridplot = lines!(
        po.blockscene, θgridpoints;
        color = po.θgridcolor,
        linestyle = po.θgridstyle,
        linewidth = po.θgridwidth,
        visible = po.θgridvisible
    )
    # minor grids
    rminorgridplot = lines!(
        po.blockscene, rminorgridpoints;
        color = po.rminorgridcolor,
        linestyle = po.rminorgridstyle,
        linewidth = po.rminorgridwidth,
        visible = po.rminorgridvisible
    )

    θminorgridplot = lines!(
        po.blockscene, θminorgridpoints;
        color = po.θminorgridcolor,
        linestyle = po.θminorgridstyle,
        linewidth = po.θminorgridwidth,
        visible = po.θminorgridvisible
    )
    # tick labels
    rticklabelplot = text!(
        po.blockscene, rtick_pos_lbl;
        fontsize = po.rticklabelsize,
        font = po.rticklabelfont,
        color = po.rticklabelcolor,
        align = (:left, :bottom),
    )

    θticklabelplot = text!(
        po.blockscene, θtick_pos_lbl;
        fontsize = po.θticklabelsize,
        font = po.θticklabelfont,
        color = po.θticklabelcolor,
        align = (:center, :center),
    )

    clippoints = lift(spinepoints) do spinepoints
        area = pixelarea(po.scene)[]
        ext_points = Point2f[
            (left(area), bottom(area)),
            (right(area), bottom(area)),
            (right(area), top(area)),
            (left(area), top(area)),
        ]
        return GeometryBasics.Polygon(ext_points, [spinepoints])
    end

    clipcolor = lift(parent(po.blockscene).theme.backgroundcolor) do bgc
        bgc = to_color(bgc)
        if alpha(bgc) == 0f0
            return to_color(:white)
        else
            return RGBf(red(bgc), blue(bgc), green(bgc))
        end
    end

    clipplot = poly!(
        po.blockscene,
        clippoints,
        color = clipcolor,
        space = :pixel,
        strokewidth = 0,
        visible = po.clip,
    )

    translate!.((spineplot, rgridplot, θgridplot, rminorgridplot, θminorgridplot, rticklabelplot, θticklabelplot), 0, 0, -100)
    translate!.((spineplot, rticklabelplot, θticklabelplot), 0, 0, 100)
    translate!(clipplot, 0, 0, 99)

    return (spineplot, rgridplot, θgridplot, rminorgridplot, θminorgridplot, rticklabelplot, θticklabelplot)

end

function calculate_polar_title_position(area, titlegap, align, θaxisprotrusion)
    x::Float32 = if align === :center
        area.origin[1] + area.widths[1] / 2
    elseif align === :left
        area.origin[1]
    elseif align === :right
        area.origin[1] + area.widths[1]
    else
        error("Title align $align not supported.")
    end

    # local subtitlespace::Float32 = if ax.subtitlevisible[] && !iswhitespace(ax.subtitle[])
    #     boundingbox(subtitlet).widths[2] + subtitlegap
    # else
    #     0f0
    # end

    yoffset::Float32 = top(area) + titlegap + θaxisprotrusion.top #=+
        subtitlespace=#

    return Point2f(x, yoffset)
end

# allow it to be plotted to
# the below causes a stack overflow
# Makie.can_be_current_axis(po::PolarAxis) = true

function Makie.plot!(
    po::PolarAxis, P::Makie.PlotFunc,
    attributes::Makie.Attributes, args...;
    kw_attributes...)

    allattrs = merge(attributes, Attributes(kw_attributes))

    # cycle = get_cycle_for_plottype(allattrs, P)
    # add_cycle_attributes!(allattrs, P, cycle, po.cycler, po.palette)

    plot = Makie.plot!(po.scene, P, allattrs, args...)

    autolimits!(po)

    # # some area-like plots basically always look better if they cover the whole plot area.
    # # adjust the limit margins in those cases automatically.
    # needs_tight_limits(plot) && tightlimits!(po)

    # reset_limits!(po)
    plot
end


function Makie.plot!(P::Makie.PlotFunc, po::PolarAxis, args...; kw_attributes...)
    attributes = Makie.Attributes(kw_attributes)
    Makie.plot!(po, P, attributes, args...)
end
function Makie.autolimits!(po::PolarAxis)
    datalims = Rect2f(data_limits(po.scene))
    # projected_datalims = Makie.apply_transform(po.scene.transformation.transform_func[], datalims)
    # @show projected_datalims
    po.limits[] = (datalims.origin[1], datalims.origin[1] + datalims.widths[1])
    # @show po.limits[]
    # adjustcam!(po, po.limits[])
    # notify(po.limits)
end

function rlims!(po::PolarAxis, rs::NTuple{2, <: Real})
    po.limits[] = rs
end

function rlims!(po::PolarAxis, rmin::Real, rmax::Real)
    po.limits[] = (rmin, rmax)
end


"Adjust the axis's scene's camera to conform to the given r-limits"
function adjustcam!(po::PolarAxis, limits::NTuple{2, <: Real}, θlims::NTuple{2, <: Real} = (-1.0π, 1.0π))
    @assert limits[1] ≤ limits[2]
    scene = po.scene
    # We transform our limits to transformed space, since we can
    # operate linearly there
    # @show boundingbox(scene)
    target = Makie.apply_transform((scene.transformation.transform_func[]), BBox(limits..., θlims...))
    # @show target
    area = scene.px_area[]
    Makie.update_cam!(scene, target)
    notify(scene.camera_controls.area)
    return
end



# ? ---------------------------- Polar histogram --------------------------- ? #
@recipe(PolarHist, values) do scene
    Attributes(
        bins = 15, # Int or iterable of edges
        normalization = :none,
        weights = automatic,
        cycle = [:color => :patchcolor],
        color = theme(scene, :patchcolor),
        offset = 0.0,
        fillto = automatic,
        scale_to = nothing,
        strokewidth = 2,
        bar_labels = nothing,
        flip_labels_at = Inf,
        label_color = theme(scene, :textcolor),
        over_background_color = automatic,
        over_bar_color = automatic,
        label_offset = 5,
        label_font = theme(scene, :font),
        label_size = 20,
        label_formatter = bar_label_formatter
    )
end

function pick_polarhist_edges(vals, bins)
    if bins isa Int
        return range(-1.0π, 1.0π, length = bins)
    else
        if !issorted(bins)
            error("Histogram bins are not sorted: $bins")
        end
        return bins
    end
end

function Makie.plot!(plot::PolarHist)

    values = lift(x->mod.(x .+ π, 2*π) .- π, plot.values)
    edges = lift(pick_polarhist_edges, plot, values, plot.bins)

    points = lift(plot, edges, plot.normalization, plot.scale_to,
                  plot.weights) do edges, normalization, scale_to, wgts
        centers, weights = _hist_center_weights(values, edges, normalization, scale_to, wgts)
        return Point2f.(centers, weights)
    end
    widths = lift(diff, plot, edges)
    color = lift(plot, plot.color) do color
        if color === :values
            return last.(points[])
        else
            return color
        end
    end

    bar_labels = lift(plot, plot.bar_labels) do x
        x === :values ? :y : x
    end
    # plot as an oversampled line
    # ? For each interval, get a list of thetas and rs
    θs = lift(edges) do edges
            [edges[i]:0.01:edges[i+1] for i in 1:length(edges)-1]
        end
    rs = lift(points, θs) do points, θs
            [fill(last(points[i]), length(θ)) for (i, θ) in enumerate(θs)]
        end

    # ? Polygons
    pgons = lift(rs, θs) do rs, θs
        return [Polygon(Point2f.(zip([r..., 0], [θ..., 0]))) for (r, θ) in zip(rs, θs)]
    end
    # intervals = lift(x->vcat(x...), θs)
    # rs = lift(x->vcat(x...), rs)
    # push!(intervals[], intervals[][1]) # Wrap around
    # push!(rs[], rs[][1])



    # lp = lines!(plot, rs[], intervals[]; plot.attributes..., color=color)
    poly!(plot, pgons; plot.attributes..., color=color)
    plot
end

# # ? ----------------------------- Polar density ---------------------------- ? #
# @recipe(PolarDensity) do scene
#     Theme(
#         color = theme(scene, :patchcolor),
#         colormap = theme(scene, :colormap),
#         colorrange = Makie.automatic,
#         strokecolor = theme(scene, :patchstrokecolor),
#         strokewidth = theme(scene, :patchstrokewidth),
#         linestyle = nothing,
#         strokearound = false,
#         npoints = 200,
#         offset = 0.0,
#         direction = :x,
#         boundary = (-1.0π, 1.0π),
#         bandwidth = automatic,
#         weights = automatic,
#         cycle = [:color => :patchcolor],
#         inspectable = theme(scene, :inspectable)
#     )
# end

# function plot!(plot::PolarDensity{<:Tuple{<:AbstractVector}})
#     θ = plot[1]

#     lowerupper = lift(plot, θ, plot.direction, plot.boundary, plot.offset,
#         plot.npoints, plot.bandwidth, plot.weights) do θ, dir, bound, offs, n, bw, weights

#         k = KernelDensity.kde(θ;
#             npoints = n,
#             (bound === automatic ? NamedTuple() : (boundary = bound,))...,
#             (bw === automatic ? NamedTuple() : (bandwidth = bw,))...,
#             (weights === automatic ? NamedTuple() : (weights = StatsBase.weights(weights),))...
#         )

#         if dir === :x
#             lowerv = Point2f.(k.x, offs)
#             upperv = Point2f.(k.x, offs .+ k.density)
#         elseif dir === :y
#             lowerv = Point2f.(offs, k.x)
#             upperv = Point2f.(offs .+ k.density, k.x)
#         else
#             error("Invalid direction $dir, only :x or :y allowed")
#         end
#         (lowerv, upperv)
#     end

#     linepoints = lift(plot, lowerupper, plot.strokearound) do lu, sa
#         if sa
#             ps = copy(lu[2])
#             push!(ps, lu[1][end])
#             push!(ps, lu[1][1])
#             push!(ps, lu[1][2])
#             ps
#         else
#             lu[2]
#         end
#     end

#     lower = Observable(Point2f[])
#     upper = Observable(Point2f[])

#     on(plot, lowerupper) do (l, u)
#         lower.val = l
#         upper[] = u
#     end
#     notify(lowerupper)

#     colorobs = Observable{RGBColors}()
#     map!(plot, colorobs, plot.color, lowerupper, plot.direction) do c, lu, dir
#         if (dir === :x && c === :x) || (dir === :y && c === :y)
#             dim = dir === :x ? 1 : 2
#             return Float32[l[dim] for l in lu[1]]
#         elseif (dir === :y && c === :x) || (dir === :x && c === :y)
#             o = Float32(plot.offset[])
#             dim = dir === :x ? 2 : 1
#             return vcat(Float32[l[dim] - o for l in lu[1]], Float32[l[dim] - o for l in lu[2]])::Vector{Float32}
#         else
#             return to_color(c)
#         end
#     end

#     band!(plot, lower, upper, color = colorobs, colormap = plot.colormap,
#         colorrange = plot.colorrange, inspectable = plot.inspectable)
#     l = lines!(plot, linepoints, color = plot.strokecolor,
#         linestyle = plot.linestyle, linewidth = plot.strokewidth,
#         inspectable = plot.inspectable)
#     plot
# end

# end # module
