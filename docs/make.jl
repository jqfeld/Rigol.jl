using Rigol
using Documenter

DocMeta.setdocmeta!(Rigol, :DocTestSetup, :(using Rigol); recursive=true)

makedocs(;
    modules=[Rigol],
    authors="Jan Kuhfeld <jan.kuhfeld@rub.de> and contributors",
    sitename="Rigol.jl",
    format=Documenter.HTML(;
        canonical="https://jqfeld.github.io/Rigol.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/jqfeld/Rigol.jl",
    devbranch="main",
)
