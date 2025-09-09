using PomlSDK
using Documenter

DocMeta.setdocmeta!(PomlSDK, :DocTestSetup, :(using PomlSDK); recursive=true)

makedocs(;
    modules=[PomlSDK],
    authors="imohag9 <souidi.hamza90@gmail.com> and contributors",
    sitename="PomlSDK.jl",
    format=Documenter.HTML(;
        canonical="https://imohag9.github.io/PomlSDK.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Getting Started" => "getting_started.md",
        "Usage Guide" => [
            "usage/creating_prompts.md",
            "usage/hierarchy_management.md",
            "usage/content_types.md",
            "usage/tool_integration.md"
        ],
        "API Reference" => "api.md",
        "Examples" => [
            "examples/basic_prompt.md",
            "examples/table_creation.md",
            "examples/tool_usage.md",
            "examples/metadata.md"
        ],
        "POML Standard" => "poml_standard.md"
    ],
)

deploydocs(;
    repo="github.com/imohag9/PomlSDK.jl",
    devbranch="main",
)
