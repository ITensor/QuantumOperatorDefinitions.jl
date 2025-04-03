using GradedArrays: GradedArrays
using ITensorBase: ITensor, Index, gettag, hastag, prime, settag
using NamedDimsArrays: dename
using QuantumOperatorDefinitions: OpName, SiteType, StateName, op, site, sites, state
using Test: @test, @testset

@testset "ITensorBaseExt" begin
  i = Index(SiteType("S=1/2"))
  @test gettag(i, "sitetype") == "S=1/2"

  i = Index(2)
  a = state("0", i)
  @test a == ITensor(state("0", 2), i)
  @test a == state("0", (i,))
  @test a == ITensor(StateName("0"), i)
  @test a == ITensor(StateName("0"), (i,))

  i = settag(Index(2), "sitetype", "S=1/2")
  a = state("X+", i)
  @test a == ITensor(state("X+", SiteType("S=1/2")), i)

  i = Index(2)
  a = op("X", i)
  @test a == ITensor(op("X", 2), (prime(i), i))
  @test a == op("X", (i,))
  @test a == ITensor(OpName("X"), i)
  @test a == ITensor(OpName("X"), (i,))

  i1 = Index(2)
  i2 = Index(2)
  i1′ = prime(i1)
  i2′ = prime(i2)
  a = ITensor(OpName("CX"), (i1, i2))
  @test a == ITensor(op("CX", (2, 2)), (i1′, i2′, i1, i2))
  @test a[i1′[1], i2′, i1[1], i2] == op("I", i2)
  @test a[i1′[2], i2′, i1[1], i2] == zeros(i2′, i2)
  @test a[i1′[1], i2′, i1[2], i2] == zeros(i2′, i2)
  @test a[i1′[2], i2′, i1[2], i2] == op("X", i2)

  i1 = Index(3)
  i2 = Index(2)
  i1′ = prime(i1)
  i2′ = prime(i2)
  a = ITensor(OpName("CX"), (i1, i2))
  @test a == ITensor(op("CX", (3, 2)), (i1′, i2′, i1, i2))
  @test a[i1′[1], i2′, i1[1], i2] == op("I", i2)
  @test a[i1′[2], i2′, i1[1], i2] == zeros(i2′, i2)
  @test a[i1′[3], i2′, i1[1], i2] == zeros(i2′, i2)
  @test a[i1′[1], i2′, i1[2], i2] == zeros(i2′, i2)
  @test a[i1′[2], i2′, i1[2], i2] == op("I", i2)
  @test a[i1′[3], i2′, i1[2], i2] == zeros(i2′, i2)
  @test a[i1′[1], i2′, i1[3], i2] == zeros(i2′, i2)
  @test a[i1′[2], i2′, i1[3], i2] == zeros(i2′, i2)
  @test a[i1′[3], i2′, i1[3], i2] == op("X", i2)

  i1 = Index(2)
  i2 = Index(3)
  i1′ = prime(i1)
  i2′ = prime(i2)
  a = ITensor(OpName("CX"), (i1, i2))
  @test a == ITensor(op("CX", (2, 3)), (i1′, i2′, i1, i2))
  @test a[i1′[1], i2′, i1[1], i2] == op("I", i2)
  @test a[i1′[2], i2′, i1[1], i2] == zeros(i2′, i2)
  @test a[i1′[1], i2′, i1[2], i2] == zeros(i2′, i2)
  @test a[i1′[2], i2′, i1[2], i2] == op("X", i2)

  i = site(Index, "Qudit"; dim=3)
  @test dename(i) == Base.OneTo(3)
  @test gettag(i, "sitetype") == "Qudit"
  @test !hastag(i, "site")

  for is in (
    sites(Index, "Qudit", 3; dim=3),
    sites(Index, "Qudit", 1:3; dim=3),
    sites(Index, "Qudit", (1, 2, 3); dim=3),
  )
    @test length(is) == 3
    for (pos, i) in pairs(is)
      @test dename(i) == Base.OneTo(3)
      @test gettag(i, "sitetype") == "Qudit"
      @test gettag(i, "site") == "$pos"
    end
  end

  is = sites(Index, "Qudit", 2:4; dim=3)
  @test dename(is[1]) == Base.OneTo(3)
  @test gettag(is[1], "site") == "2"
  @test dename(is[2]) == Base.OneTo(3)
  @test gettag(is[2], "site") == "3"
  @test dename(is[3]) == Base.OneTo(3)
  @test gettag(is[3], "site") == "4"
end
