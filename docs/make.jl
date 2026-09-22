using WindTunnelUtils
using Documenter

DocMeta.setdocmeta!(WindTunnelUtils, :DocTestSetup, :(using WindTunnelUtils); recursive=true)

makedocs(;
    modules=[WindTunnelUtils],
    authors="= <pjabardo@ipt.br> and contributors",
    sitename="WindTunnelUtils.jl",
    format=Documenter.HTML(;
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)
