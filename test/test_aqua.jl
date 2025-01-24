using QuantumOperatorDefinitions: QuantumOperatorDefinitions
using Aqua: Aqua
using Test: @testset

@testset "Code quality (Aqua.jl)" begin
  Aqua.test_all(QuantumOperatorDefinitions; ambiguities=false)
end
