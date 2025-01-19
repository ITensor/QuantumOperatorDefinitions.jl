using ITensorQuantumOperatorDefinitions: ITensorQuantumOperatorDefinitions
using Documenter: Documenter, DocMeta, deploydocs, makedocs

DocMeta.setdocmeta!(
  ITensorQuantumOperatorDefinitions,
  :DocTestSetup,
  :(using ITensorQuantumOperatorDefinitions);
  recursive=true,
)

include("make_index.jl")

makedocs(;
  modules=[ITensorQuantumOperatorDefinitions],
  authors="ITensor developers <support@itensor.org> and contributors",
  sitename="ITensorQuantumOperatorDefinitions.jl",
  format=Documenter.HTML(;
    canonical="https://ITensor.github.io/ITensorQuantumOperatorDefinitions.jl",
    edit_link="main",
    assets=String[],
  ),
  pages=["Home" => "index.md", "Reference" => "reference.md"],
)

deploydocs(;
  repo="github.com/ITensor/ITensorQuantumOperatorDefinitions.jl",
  devbranch="main",
  push_preview=true,
)
