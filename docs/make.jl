using CairoMakie
using Foresight
using Documenter

DocMeta.setdocmeta!(Foresight, :DocTestSetup, :(using CairoMakie; using Foresight); recursive=true)

makedocs(;
    modules=[Foresight],
    authors="brendanjohnharris <brendanjohnharris@gmail.com> and contributors",
    repo="https://github.com/brendanjohnharris/Foresight.jl/blob/{commit}{path}#{line}",
    sitename="Foresight.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://brendanjohnharris.github.io/Foresight.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/brendanjohnharris/Foresight.jl",
    devbranch="main",
)
