using Literate: Literate
using ITensorQuantumOperatorDefinitions: ITensorQuantumOperatorDefinitions

Literate.markdown(
  joinpath(pkgdir(ITensorQuantumOperatorDefinitions), "examples", "README.jl"),
  joinpath(pkgdir(ITensorQuantumOperatorDefinitions));
  flavor=Literate.CommonMarkFlavor(),
  name="README",
)
