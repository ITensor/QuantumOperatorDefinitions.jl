using QuantumOperatorDefinitions: QuantumOperatorDefinitions
using Test: @test, @testset
@testset "Test exports" begin
  exports = [
    :QuantumOperatorDefinitions,
    Symbol("@OpName_str"),
    Symbol("@SiteType_str"),
    Symbol("@StateName_str"),
    :OpName,
    :SiteType,
    :StateName,
    :⊗,
    :op,
    :state,
  ]
  @test issetequal(names(QuantumOperatorDefinitions), exports)
end
