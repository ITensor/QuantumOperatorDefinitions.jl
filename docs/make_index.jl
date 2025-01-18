using Literate: Literate
using ITensorQuantumOperatorDefinitions: ITensorQuantumOperatorDefinitions

Literate.markdown(
  joinpath(pkgdir(ITensorQuantumOperatorDefinitions), "examples", "README.jl"),
  joinpath(pkgdir(ITensorQuantumOperatorDefinitions), "docs", "src");
  flavor=Literate.DocumenterFlavor(),
  name="index",
)
