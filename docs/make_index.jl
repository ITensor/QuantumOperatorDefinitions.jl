using Literate: Literate
using QuantumOperatorDefinitions: QuantumOperatorDefinitions

Literate.markdown(
  joinpath(pkgdir(QuantumOperatorDefinitions), "examples", "README.jl"),
  joinpath(pkgdir(QuantumOperatorDefinitions), "docs", "src");
  flavor=Literate.DocumenterFlavor(),
  name="index",
)
