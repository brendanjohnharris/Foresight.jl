using CairoMakie
using Makie
import Makie.Linestyle
using Foresight
using Documenter
using Documenter: Documenter
using Documenter.MarkdownAST
using Documenter.MarkdownAST: @ast
using DocumenterVitepress
using Markdown

include("docs_blocks.jl")

format = DocumenterVitepress.MarkdownVitepress(;
                                               repo = "github.com/brendanjohnharris/Foresight.jl",
                                               devbranch = "main",
                                               devurl = "dev")

makedocs(;
         authors = "brendanjohnharris <brendanjohnharris@gmail.com> and contributors",
         sitename = "Foresight",
         format,
         pages = ["Home" => "index.md",
             "Colormaps" => "colors.md",
             "Utilities" => "utilities.md",
             "Layouts" => "layouts.md",
             "Recipes" => "recipes.md",
             "Reference" => ["Hill" => "reference/hill.md",
                 "Ziggurat" => "reference/ziggurat.md",
                 "Bandwidth" => "reference/bandwidth.md",
                 "PolarHist" => "reference/polarhist.md",
                 "PolarDensity" => "reference/polardensity.md",
                 "Prism" => "reference/prism.md",
                 "CovEllipse" => "reference/covellipse.md"
             ]])

DocumenterVitepress.deploydocs(;
                               repo = "github.com/brendanjohnharris/Foresight.jl",
                               target = "build", # this is where Vitepress stores its output
                               branch = "gh-pages",
                               devbranch = "main",
                               push_preview = true)
