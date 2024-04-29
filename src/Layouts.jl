export addlabels!, OnePanel, TwoPanel, FourPanel, SixPanel, subdivide

# * A set of consistent figure layouts

function OnePanel(args...; kwargs...)
    f = Figure(args...; size = (360, 360))
    return f
end
function TwoPanel(args...; kwargs...)
    f = Figure(args...; size = (720, 320))
    return f
end
function FourPanel(args...; kwargs...)
    f = Figure(args...; size = (720, 640))
    return f
end
function SixPanel(args...; kwargs...)
    f = Figure(args...; size = (720, 960))
    return f
end

function subdivide(f, nrows, ncols)
    grid = [f[i, j] for i in 1:nrows, j in 1:ncols]
    return permutedims(grid, (2, 1))
end

function addlabels!(f, text = nothing; kwargs...)
    content = f.layout.content
    allowedblocks = [Axis, Axis3, PolarAxis, LScene]
    content = filter(x -> any(isa.([x.content], allowedblocks)), content)
    n = prod(length(content))
    spans = [[c.rows, c.cols] for c in getfield.(content, :span)]
    idxs = sortperm(spans)

    if isnothing(text)
        text = Char.(1:n) .+ 96
        text = ["($s)" for s in text]
    end
    if length(text) != n
        error("Number of labels does not match the number of valid blocks ($allowedblocks)")
    end

    for (i, l) in enumerate(content[idxs])
        span = l.span
        Label(f[span.rows, span.cols, TopLeft()], halign = :left, valign = :bottom,
              text = text[i],
              fontsize = 22, padding = (-5, 0, 5, 0), kwargs...)
    end
end
