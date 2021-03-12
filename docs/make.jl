using MyUtils
using Documenter

DocMeta.setdocmeta!(MyUtils, :DocTestSetup, :(using MyUtils); recursive=true)

makedocs(;
    modules=[MyUtils],
    authors="genkuroki <genkuroki@gmail.com> and contributors",
    repo="https://github.com/genkuroki/MyUtils.jl/blob/{commit}{path}#{line}",
    sitename="MyUtils.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://genkuroki.github.io/MyUtils.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/genkuroki/MyUtils.jl",
)
