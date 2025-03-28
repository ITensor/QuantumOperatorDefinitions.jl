using QuantumOperatorDefinitions: QuantumOperatorDefinitions
using Documenter: Documenter, DocMeta, deploydocs, makedocs

DocMeta.setdocmeta!(
  QuantumOperatorDefinitions, :DocTestSetup, :(using QuantumOperatorDefinitions); recursive=true
)

include("make_index.jl")

makedocs(;
  modules=[QuantumOperatorDefinitions],
  authors="ITensor developers <support@itensor.org> and contributors",
  sitename="QuantumOperatorDefinitions.jl",
  format=Documenter.HTML(;
    canonical="https://itensor.github.io/QuantumOperatorDefinitions.jl",
    edit_link="main",
    assets=["assets/favicon.ico", "assets/extras.css"],
  ),
  pages=["Home" => "index.md", "Reference" => "reference.md"],
)

deploydocs(;
  repo="github.com/ITensor/QuantumOperatorDefinitions.jl", devbranch="main", push_preview=true
)
