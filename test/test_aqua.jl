using ITensorQuantumOperatorDefinitions: ITensorQuantumOperatorDefinitions
using Aqua: Aqua
using Test: @testset

@testset "Code quality (Aqua.jl)" begin
  Aqua.test_all(ITensorQuantumOperatorDefinitions; ambiguities=false)
end
