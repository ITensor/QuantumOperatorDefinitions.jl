using ITensorBase: ITensor, Index, prime
using QuantumOperatorDefinitions: op, state
using Test: @test, @testset

@testset "QuantumOperatorDefinitionsITensorBaseExt" begin
  i = Index(2)

  a = op("X", i)
  @test a == ITensor([0 1; 1 0], (prime(i), i))

  a = state(1, i)
  @test a == ITensor([1, 0], (i,))
end
