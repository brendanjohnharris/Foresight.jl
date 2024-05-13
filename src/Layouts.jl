export addlabels!, OnePanel, TwoPanel, FourPanel, SixPanel, subdivide
import Makie.GridLayoutBase.GridContent

# * A set of consistent figure layouts
function _panels(args...; size = (720, 300), scale = 1, kwargs...)
    f = Figure(args...; size = size .* scale, kwargs...)
    return f
end
function OnePanel(args...; kwargs...)
    f = _panels(args...; size = (360, 300), kwargs...)
    return f
end
function TwoPanel(args...; kwargs...)
    f = _panels(args...; size = (720, 300), kwargs...)
    return f
end
function FourPanel(args...; kwargs...)
    f = _panels(args...; size = (720, 600), kwargs...)
    return f
end
function SixPanel(args...; kwargs...)
    f = _panels(args...; size = (720, 900), kwargs...)
    return f
end

function subdivide(f, nrows::Int, ncols::Int)
    grid = [f[i, j] for i in 1:nrows, j in 1:ncols]
    return permutedims(grid, (2, 1))
end
function subdivide(f, sz::Tuple{Int, Int})
    nrows, ncols = sz
    subdivide(f, nrows, ncols)
end

function addlabels!(f, text = nothing;
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
        x.layoutobservables.gridcontent[].parent
    end
    content = unique(content)

    function getposition(g)
        [1, -1] .* Makie.GridLayoutBase.tight_bbox(g).origin |> reverse
    end
    content = sort(content, by = getposition)

    n = prod(length(content))

    if isnothing(text)
        text = Char.(1:n) .+ 96
        text = ["($s)" for s in text]
    end
    if length(text) != n
        error("Number of labels does not match the number of valid blocks ($allowedblocks)")
    end

    for (i, l) in enumerate(content)
        Label(l[1, 1, TopLeft()], halign = :left, valign = :bottom,
              text = text[i],
              fontsize = 22, padding = (-5, 0, 5, 0), kwargs...)
    end
end
