var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = Foresight","category":"page"},{"location":"#Foresight","page":"Home","title":"Foresight","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for Foresight.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"using CairoMakie\nusing CairoMakie.Makie.PlotUtils\nusing CairoMakie.Colors\nusing Foresight\nshowable(::MIME\"text/plain\", ::AbstractVector{C}) where {C<:Colorant} = false\nshowable(::MIME\"text/plain\", ::PlotUtils.ContinuousColorGradient) = false","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [Foresight]","category":"page"},{"location":"#Foresight.axiscolorbar-Tuple{Any, Vararg{Any}}","page":"Home","title":"Foresight.axiscolorbar","text":"axiscolorbar(ax, args...; kwargs...)\n\nCreate a colorbar for the given ax axis. The args argument is passed to the Colorbar constructor, and the kwargs argument is passed to the Colorbar constructor as keyword arguments. The position argument specifies the position of the colorbar relative to the axis, and can be one of :rt (right-top), :rb (right-bottom), :lt (left-top), :lb (left-bottom). The default value is :rt.\n\nExample\n\nf = Figure()\nax = Axis(f[1, 1])\nx = -5:0.01:5\np = plot!(ax, x, x->sinc(x), color=1:length(x), colormap=sunset)\naxiscolorbar(ax, p; label=\"Time (m)\")\n\n\n\n\n\n","category":"method"},{"location":"#Foresight.brighten-Union{Tuple{T}, Tuple{T, Any}} where T","page":"Home","title":"Foresight.brighten","text":"brighten(c::T, β)\n\nBrighten a color c by a factor of β by blending it with white. β should be between 0 and 1.\n\nExample\n\nbrighten(cornflowerblue, 0.5)\n\n\n\n\n\n","category":"method"},{"location":"#Foresight.clip","page":"Home","title":"Foresight.clip","text":"tmpfile = clip(fig=Makie.current_figure(), fmt=:png; kwargs...)\n\nSave the current figure to a temporary file and copy it to the clipboard. kwargs are passed to Makie.save.\n\nExample\n\nf = plot(-5:0.01:5, x->sinc(x))\nclip(f)\n\n\n\n\n\n","category":"function"},{"location":"#Foresight.darken-Union{Tuple{T}, Tuple{T, Any}} where T","page":"Home","title":"Foresight.darken","text":"darken(c::T, β)\n\nDarken a color c by a factor of β by blending it with black. β should be between 0 and 1.\n\nExample\n\ndarken(cornflowerblue, 0.5)\n\n\n\n\n\n","category":"method"},{"location":"#Foresight.demofigure-Tuple{}","page":"Home","title":"Foresight.demofigure","text":"demofigure()\n\nProduce a figure showcasing the current theme.\n\n\n\n\n\n","category":"method"},{"location":"#Foresight.foresight-Tuple","page":"Home","title":"Foresight.foresight","text":"foresight(options...; font=foresightfont())\n\nReturn the default Foresight theme. The options argument can be used to modify the default values, by passing keyword arguments with the names of the attributes to be changed and their new values.\n\nSome vailable options are:\n\n:dark: Use a dark background and light text.\n:transparent: Make the background transparent.\n:minorgrid: Show minor gridlines.\n:serif: Use a serif font.\n:redblue: Use a red-blue colormap.\n:gray: Use a grayscale colormap.\n\n\n\n\n\n","category":"method"},{"location":"#Foresight.freeze!-Tuple{Union{Axis, Axis3}}","page":"Home","title":"Foresight.freeze!","text":"freeze!(ax::Union{Axis, Axis3, Figure}=current_figure())\n\nFreeze the limits of an Axis or Axis3 object at their current values.\n\nExample\n\nax = Axis();\nplot!(ax, -5:0.01:5, x->sinc(x))\nfreeze!(ax)\n\n\n\n\n\n","category":"method"},{"location":"#Foresight.importall-Tuple{Any}","page":"Home","title":"Foresight.importall","text":"importall(module)\n\nReturn an array of expressions that can be used to import all names from a module.\n\nExample\n\nimportall(module) .|> eval\n\n\n\n\n\n","category":"method"},{"location":"#Foresight.lscientific","page":"Home","title":"Foresight.lscientific","text":"lscientific(x::Real, sigdigits=2)\n\nReturn a string representation of a number in scientific notation with a specified number of significant digits. This is not an L-string.\n\nExample\n\nlscientific(1/123.456, 3) # \"8.10 \\times 10^{-3}\"\n\n\n\n\n\n","category":"function"},{"location":"#Foresight.prism-Tuple{Any}","page":"Home","title":"Foresight.prism","text":"prism(x, Y; [palette=[:cornflowerblue, :crimson, :cucumber], colormode=:top, verbose=false.])\n\nColor a covariance matrix each element's contribution to each of the top k principal components, where k is the length of the supplied color palette (defaults to the number of principal component weights given). Provide as positional arguments a vector x of N row names and an N×N covariance matrix Y.\n\nKeyword Arguments\n\npalette: a vector containing a color for each principal component.\ncolormode: how to color the covariance matrix. :raw gives no coloring by principal components, :top is a combination of the top three PC colors (default) and :all is a combination of all PC colors, where PCN = :black if N > length(palette).\nverbose: whether to print the feature weights to the console\n\n\n\n\n\n","category":"method"},{"location":"#Foresight.scientific","page":"Home","title":"Foresight.scientific","text":"scientific(x::Real, sigdigits=2)\n\nReturn a string representation of a number in scientific notation with a specified number of significant digits.\n\nArguments\n\nx::Real: The number to be formatted.\nsigdigits::Int=2: The number of significant digits to display.\n\nReturns\n\nA string representation of the number in scientific notation with the specified number of significant digits.\n\nExample\n\nscientific(1/123.456, 3) # \"8.10 × 10⁻³\"\n\n\n\n\n\n","category":"function"},{"location":"#Foresight.seethrough","page":"Home","title":"Foresight.seethrough","text":"seethrough(C::ContinuousColorGradient, start=0.0, stop=1.0)\n\nConvert a color gradient into a transparent version\n\nExamples\n\nC = sunrise;\ntransparent_gradient = seethrough(C)\n\n\n\n\n\n","category":"function"},{"location":"#Foresight.widen","page":"Home","title":"Foresight.widen","text":"Slightly widen an interval by a fraction δ\n\n\n\n\n\n","category":"function"},{"location":"#Foresight.@default_theme!-Tuple{Any}","page":"Home","title":"Foresight.@default_theme!","text":"@default_theme!(thm)\n\nSet the default theme to thm and save it as a preference. The change will take effect after restarting Julia.\n\nExample\n\n    @default_theme!(foresight())\n\n\n\n\n\n","category":"macro"}]
}
