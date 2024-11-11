export addlabels!, OnePanel, TwoPanel, FourPanel, SixPanel, subdivide
import Makie.GridLayoutBase.GridContent

# * A set of consistent figure layouts
function _panels(args...; size = (720, 270), scale = 1.25, kwargs...)
    f = Figure(args...; size = size .* scale, kwargs...)
    return f
end
function OnePanel(args...; kwargs...)
    f = _panels(args...; size = (360, 270), kwargs...)
    return f
end
function TwoPanel(args...; kwargs...)
    f = _panels(args...; size = (720, 270), kwargs...)
    return f
end
function FourPanel(args...; kwargs...)
    f = _panels(args...; size = (720, 540), kwargs...)
    return f
end
function SixPanel(args...; kwargs...)
    f = _panels(args...; size = (720, 810), kwargs...)
    return f
end

"""
    subdivide(f, nrows::Int, ncols::Int)::Matrix{GridPosition}

Subdivides a figure `f` into a grid with specified number of rows and columns.
Returns the corresponding grid positions

# Example
```julia
f = Figure()
gs = subdivide(f, 2, 2)
axs = Axis.(gs)
display(f)
```
"""
function subdivide(f, nrows::Int, ncols::Int)
    grid = [f[i, j] for i in 1:nrows, j in 1:ncols]
    return permutedims(grid, (2, 1))
end
function subdivide(f, sz::Tuple{Int, Int})
    nrows, ncols = sz
    subdivide(f, nrows, ncols)
end

"""
    addlabels!(gridpositions, f::Figure, [text]; dims=2, kwargs...)

Add labels to a provided grid layout. The labels are incremented in the linear order of the
grid positions.

## Arguments
- `gridpositions`: An iterator of `GridPosition`s as produced by e.g. [`subdivide`](@ref).
- `f`: The figure associated with the grid positions (optional)
- `text`: Text to be displayed in the labels, as either an interator of strings or a
  function applied to the integer indices of the grid positions [optional; defaults to (a),
  (b), ...]
- `kwargs`: Keyword arguments to be passed to the `Label` function.

## Examples
```julia
f = Figure()
gs = subdivide(f, 2, 2)
addlabels!(gs)
display(f)
```
"""
function addlabels!(gridpositions, f::Figure = first(gridpositions).layout.parent,
                    text = nothing; kwargs...)
    if !(eltype(gridpositions) <: GridPosition)
        throw(TypeError(:addlabels!, "Foresight", GridPosition, first(gridpositions)))
    end

    n = length(gridpositions)

    if isnothing(text)
        text = Char.(1:n) .+ 96
        text = ["($s)" for s in text]
    end
    if text isa Function
        text = text.(1:n)
    end
    if length(text) != n
        error("Number of labels does not match the number of valid blocks")
    end

    for (i, l) in enumerate(gridpositions)
        Label(l[1, 1, TopLeft()], halign = :left, valign = :bottom,
              text = text[i],
              fontsize = 22, padding = (-5, 0, 5, 0), kwargs...)
    end
end

"""
    addlabels!(f::Figure, [text]; dims=2, allowedblocks = [Axis, Axis3, PolarAxis], recurse =
    [GridContent, GridLayout], kwargs...)

Add labels to a provided grid layout, automatically searching for blocks to label.

## Arguments
- `f`: The figure to add labels to.
- `text`: Text to be displayed in the labels, as either an interator of strings or a
  function applied to the integer indices of the grid positions [optional; defaults to (a),
  (b), ...]
- `dims`: The dimension to increment labels; `1` for top-to-bottom increases (column major),
  or `2` for right-to-left increases (row-major; default).
- `allowedblocks`: The types of blocks to consider for labelling (optional; defaults to `[Axis,
  Axis3, PolarAxis]`).
- `recurse`: The types of blocks to recurse into for searching the `allowedblocks`
  (optional; defaults to `[GridContent, GridLayout]`).
- `kwargs`: Keyword arguments to be passed to the `Label` function.

## Examples
```julia
f = Foresight.demofigure()
addlabels!(f)
display(f)
```
See also: [`addlabels!`](@ref)
"""
function addlabels!(f::Figure, text = nothing;
                    dims = 2,
                    allowedblocks = [Axis, Axis3, PolarAxis],
                    recurse = [GridContent, GridLayout], kwargs...)
    content = [Vector{Any}(f.layout.content)]
    function isinrecurse(x)
        types = typeof.(x)
        checks = t -> any([t <: r for r in recurse])
        checks.(types)
    end
    while any(isinrecurse(only(content)))
        contents = only(content)
        map(enumerate(contents)) do (i, c)
            if any(isa.([c], recurse))
                contents[i] = c.content
            end
        end
        content[1] = vcat(contents...) |> Vector{Any}
    end
    content = only(content)
    content = filter(content) do x
        any(isa.([x], allowedblocks))
    end
    content = map(content) do x
        b = x.layoutobservables.gridcontent[]
        c = b.parent[b.span.rows, b.span.cols]
        p = x.layoutobservables.computedbbox[].origin .* [1, -1]
        return c, p
    end
    position = last.(content)
    if dims == 2
        position = reverse.(position)
    end
    content = first.(content)
    content = unique(content)

    idxs = indexin(unique(content), content)
    content = content[idxs]
    position = position[idxs]

    idxs = sortperm(position)
    content = content[idxs]
    position = position[idxs]

    addlabels!(content, f, text; kwargs...)
end
