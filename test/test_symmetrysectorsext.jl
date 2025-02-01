using BlockArrays: AbstractBlockArray, blocklengths
using BlockSparseArrays: BlockSparseArray
using GradedUnitRanges: blocklabels
using ITensorBase: ITensor, Index, gettag, prime, settag
using QuantumOperatorDefinitions: OpName, SiteType, StateName, op, state
using SymmetrySectors: SectorProduct, U1, Z
using NamedDimsArrays: dename
using Test: @test, @test_broken, @testset

@testset "SymmetrySectorsExt" begin
  t = SiteType("S=1/2"; gradings=("Sz",))
  r = AbstractUnitRange(t)
  @test r == 1:2
  @test blocklabels(r) == [SectorProduct((; Sz=U1(0))), SectorProduct((; Sz=U1(1)))]
  @test blocklengths(r) == [1, 1]

  t = SiteType("Electron"; gradings=("Nf", "Sz"))
  r = AbstractUnitRange(t)
  @test r == 1:4
  @test blocklabels(r) == [
    SectorProduct((; Nf=U1(0), Sz=U1(0))),
    SectorProduct((; Nf=U1(1), Sz=U1(1))),
    SectorProduct((; Nf=U1(1), Sz=U1(-1))),
    SectorProduct((; Nf=U1(2), Sz=U1(0))),
  ]
  @test blocklengths(r) == [1, 1, 1, 1]

  t = SiteType("Electron"; gradings=("Nf" => "NfA", "Sz" => "SzA"))
  r = AbstractUnitRange(t)
  @test r == 1:4
  @test blocklabels(r) == [
    SectorProduct((; NfA=U1(0), SzA=U1(0))),
    SectorProduct((; NfA=U1(1), SzA=U1(1))),
    SectorProduct((; NfA=U1(1), SzA=U1(-1))),
    SectorProduct((; NfA=U1(2), SzA=U1(0))),
  ]
  @test blocklengths(r) == [1, 1, 1, 1]

  t = SiteType("Electron"; gradings=("NfParity", "Sz"))
  r = AbstractUnitRange(t)
  @test r == 1:4
  @test blocklabels(r) == [
    SectorProduct((; NfParity=Z{2}(0), Sz=U1(0))),
    SectorProduct((; NfParity=Z{2}(1), Sz=U1(1))),
    SectorProduct((; NfParity=Z{2}(1), Sz=U1(-1))),
    SectorProduct((; NfParity=Z{2}(0), Sz=U1(0))),
  ]
  @test blocklengths(r) == [1, 1, 1, 1]

  t = SiteType("S=1/2"; gradings=("Sz",))
  (r1, r2) = axes(OpName("σ⁺"), (t,))
  @test blocklabels(r1) == [SectorProduct((; Sz=U1(0))), SectorProduct((; Sz=U1(1)))]
  @test blocklengths(r1) == [1, 1]
  @test blocklabels(r2) == [SectorProduct((; Sz=U1(0))), SectorProduct((; Sz=U1(-1)))]
  @test blocklengths(r2) == [1, 1]

  # TODO: There is a bug slicing `BitVector` by `GradedOneTo` in Julia 1.11,
  # investigate. See: https://github.com/ITensor/GradedUnitRanges.jl/issues/9
  t = SiteType("S=1/2"; gradings=("Sz",))
  @test state("0", t) == [1, 0] broken = VERSION ≥ v"1.11"

  # Force conversion to `Vector{Float64}` before conversion,
  # since there is a bug slicing `BitVector` by `GradedOneTo`.
  t = SiteType("S=1/2"; gradings=("Sz",))
  a = AbstractArray(2.0 * StateName("0"), t)
  @test a == [2, 0]
  @test a isa AbstractBlockArray
  # TODO: Currently slicing a dense array by graded ranges outputs a `BlockedArray`
  # rather than a `BlockSparseArray`.
  # See: https://github.com/ITensor/GradedUnitRanges.jl/issues/9
  @test_broken a isa BlockSparseArray
  (r1,) = axes(a)
  @test blocklabels(r1) == [SectorProduct((; Sz=U1(0))), SectorProduct((; Sz=U1(1)))]
  @test blocklengths(r1) == [1, 1]

  t = SiteType("S=1/2"; gradings=("Sz",))
  a = op("σ⁺", t)
  @test a == [0 2; 0 0]
  @test a isa AbstractBlockArray
  @test_broken a isa BlockSparseArray
  (r1, r2) = axes(a)
  @test blocklabels(r1) == [SectorProduct((; Sz=U1(0))), SectorProduct((; Sz=U1(1)))]
  @test blocklengths(r1) == [1, 1]
  # TODO: This is a bug in indexing with GradedUnitRangeDual, fix this.
  @test_broken blocklabels(r2) ==
    [SectorProduct((; Sz=U1(0))), SectorProduct((; Sz=U1(-1)))]
  @test blocklengths(r2) == [1, 1]
end

@testset "SymmetrySectorsExt + ITensorBaseExt" begin
  i = Index(SiteType("S=1/2"; gradings=("Sz",)))
  @test gettag(i, "sitetype") == "S=1/2"
  # TODO: Test without denaming.
  @test dename(i) == 1:2
  @test blocklabels(dename(i)) == [SectorProduct((; Sz=U1(0))), SectorProduct((; Sz=U1(1)))]
  @test blocklengths(dename(i)) == [1, 1]

  i′ = prime(i)
  a = op("σ⁺", i)
  # TODO: The indices should be `(i′, dual(i))`.
  @test a == ITensor([0 2; 0 0], (i′, i))
  a′ = dename(a)
  @test a′ isa AbstractBlockArray
  @test_broken a′ isa BlockSparseArray
  # TODO: Test these without denaming `a`.
  (r1, r2) = axes(a′)
  @test blocklabels(r1) == [SectorProduct((; Sz=U1(0))), SectorProduct((; Sz=U1(1)))]
  @test blocklengths(r1) == [1, 1]
  # TODO: This is a bug in indexing with GradedUnitRangeDual, fix this.
  @test_broken blocklabels(r2) ==
    [SectorProduct((; Sz=U1(0))), SectorProduct((; Sz=U1(-1)))]
  @test blocklengths(r2) == [1, 1]
end
