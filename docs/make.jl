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

# DocMeta.setdocmeta!(Foresight, :DocTestSetup, :(using CairoMakie; using Foresight); recursive=true)

makedocs(;
         #  modules = [Foresight],
         authors = "brendanjohnharris <brendanjohnharris@gmail.com> and contributors",
         repo = "https://github.com/brendanjohnharris/Foresight.jl/blob/{commit}{path}#{line}",
         sitename = "Foresight.jl",
         doctest = true,
         warnonly = :doctest,
         format = DocumenterVitepress.MarkdownVitepress(repo = "github.com/brendanjohnharris/Foresight.jl",
                                                        devbranch = "main",
                                                        devurl = "dev",
                                                        deploy_url = "brendanjohnharris.github.io/Foresight.jl"),
         pages = ["Home" => "index.md",
             "Colormaps" => "colors.md",
             "Utilities" => "utilities.md",
             "Layouts" => "layouts.md",
             "Recipes" => "recipes.md",
             "Reference" => ["Hill" => "reference/hill.md",
                 "Ziggurat" => "reference/ziggurat.md",
                 "Bandwidth" => "reference/bandwidth.md",
                 "Kinetic" => "reference/kinetic.md",
                 "PolarHist" => "reference/polarhist.md",
                 "PolarDensity" => "reference/polardensity.md",
                 "Prism" => "reference/prism.md",
                 "CovEllipse" => "reference/covellipse.md"
             ]])

# deploydocs(;
#            repo = "github.com/brendanjohnharris/Foresight.jl",
#            devbranch = "main",)
DocumenterVitepress.deploydocs(;
                               repo = "github.com/brendanjohnharris/Foresight.jl",
                               target = "build",
                               branch = "gh-pages",
                               devbranch = "main",
                               push_preview = true)
