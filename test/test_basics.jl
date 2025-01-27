using QuantumOperatorDefinitions: OpName, SiteType, ⊗, expand, op, opexpr, state, nsites
using LinearAlgebra: Diagonal
using Test: @test, @testset

const real_elts = (Float32, Float64)
const complex_elts = map(elt -> Complex{elt}, real_elts)
const elts = (real_elts..., complex_elts...)

@testset "QuantumOperatorDefinitions" begin
  @testset "Qubit/Qudit" begin
    # https://en.wikipedia.org/wiki/Pauli_matrices
    # https://en.wikipedia.org/wiki/Spin_(physics)#Higher_spins
    for (
      t,
      len,
      Xmat,
      Ymat,
      Zmat,
      Nmat,
      SWAPmat,
      iSWAPmat,
      RXXmat,
      RYYmat,
      RZZmat,
      Proj1mat,
      Proj2mat,
      StandardBasis12mat,
    ) in (
      (
        SiteType("Qubit"),
        2,
        [0 1; 1 0],
        [0 -im; im 0],
        [1 0; 0 -1],
        [0 0; 0 1],
        [1 0 0 0; 0 0 1 0; 0 1 0 0; 0 0 0 1],
        [1 0 0 0; 0 0 im 0; 0 im 0 0; 0 0 0 1],
        (_, θ) -> [
          cos(θ / 2) 0 0 -im*sin(θ / 2)
          0 cos(θ / 2) -im*sin(θ / 2) 0
          0 -im*sin(θ / 2) cos(θ / 2) 0
          -im*sin(θ / 2) 0 0 cos(θ / 2)
        ],
        (_, θ) -> [
          cos(θ / 2) 0 0 im*sin(θ / 2)
          0 cos(θ / 2) -im*sin(θ / 2) 0
          0 -im*sin(θ / 2) cos(θ / 2) 0
          im*sin(θ / 2) 0 0 cos(θ / 2)
        ],
        (_, θ) ->
          Diagonal([exp(-im * θ / 2), exp(im * θ / 2), exp(im * θ / 2), exp(-im * θ / 2)]),
        [1 0; 0 0],
        [0 0; 0 1],
        [0 1; 0 0],
      ),
      (
        SiteType("Qudit"; length=3),
        3,
        √2 * [0 1 0; 1 0 1; 0 1 0],
        √2 * [0 -im 0; im 0 -im; 0 im 0],
        2 * [1 0 0; 0 0 0; 0 0 -1],
        [0 0 0; 0 1 0; 0 0 2],
        [
          1 0 0 0 0 0 0 0 0
          0 0 0 1 0 0 0 0 0
          0 0 0 0 0 0 1 0 0
          0 1 0 0 0 0 0 0 0
          0 0 0 0 1 0 0 0 0
          0 0 0 0 0 0 0 1 0
          0 0 1 0 0 0 0 0 0
          0 0 0 0 0 1 0 0 0
          0 0 0 0 0 0 0 0 1
        ],
        [
          1 0 0 0 0 0 0 0 0
          0 0 0 im 0 0 0 0 0
          0 0 0 0 0 0 im 0 0
          0 im 0 0 0 0 0 0 0
          0 0 0 0 1 0 0 0 0
          0 0 0 0 0 0 0 im 0
          0 0 im 0 0 0 0 0 0
          0 0 0 0 0 im 0 0 0
          0 0 0 0 0 0 0 0 1
        ],
        (O, θ) -> exp(-im * (θ / 2) * kron(O, O)),
        (O, θ) -> exp(-im * (θ / 2) * kron(O, O)),
        (O, θ) -> exp(-im * (θ / 2) * kron(O, O)),
        [1 0 0; 0 0 0; 0 0 0],
        [0 0 0; 0 1 0; 0 0 0],
        [0 1 0; 0 0 0; 0 0 0],
      ),
    )
      @test length(t) == len
      @test size(t) == (len,)
      @test size(t, 1) == len
      @test axes(t) == (Base.OneTo(len),)
      @test axes(t, 1) == Base.OneTo(len)
      for (o, nbits, elts, ref) in (
        (OpName("X"), 1, elts, Xmat),
        (OpName("σˣ"), 1, elts, Xmat),
        (OpName("√X"), 1, complex_elts, √Xmat),
        (OpName("iX"), 1, complex_elts, im * Xmat),
        (OpName("Y"), 1, complex_elts, Ymat),
        (OpName("σʸ"), 1, complex_elts, Ymat),
        (OpName("iY"), 1, elts, im * Ymat),
        (OpName("Z"), 1, elts, Zmat),
        (OpName("σᶻ"), 1, elts, Zmat),
        (OpName("iZ"), 1, complex_elts, im * Zmat),
        (OpName("N"), 1, elts, Nmat),
        (OpName("n"), 1, elts, Nmat),
        (OpName("Phase"; θ=π / 3), 1, complex_elts, exp(im * π / 3 * Nmat)),
        (OpName("π/8"), 1, complex_elts, exp(im * π / 4 * Nmat)),
        (OpName("Rx"; θ=π / 3), 1, complex_elts, exp(-im * π / 6 * Xmat)),
        (OpName("Ry"; θ=π / 3), 1, complex_elts, exp(-im * π / 6 * Ymat)),
        (OpName("Rz"; θ=π / 3), 1, complex_elts, exp(-im * π / 6 * Zmat)),
        (OpName("SWAP"), 2, elts, SWAPmat),
        (OpName("√SWAP"), 2, complex_elts, √SWAPmat),
        (OpName("iSWAP"), 2, complex_elts, iSWAPmat),
        (OpName("√iSWAP"), 2, complex_elts, √iSWAPmat),
        (OpName("Rxx"; θ=π / 3), 2, complex_elts, RXXmat(Xmat, π / 3)),
        (OpName("RXX"; θ=π / 3), 2, complex_elts, RXXmat(Xmat, π / 3)),
        (OpName("Ryy"; θ=π / 3), 2, complex_elts, RYYmat(Ymat, π / 3)),
        (OpName("RYY"; θ=π / 3), 2, complex_elts, RYYmat(Ymat, π / 3)),
        (OpName("Rzz"; θ=π / 3), 2, complex_elts, RZZmat(Zmat, π / 3)),
        (OpName("RZZ"; θ=π / 3), 2, complex_elts, RZZmat(Zmat, π / 3)),
        (OpName("Proj"; index=1), 1, elts, Proj1mat),
        (OpName("Proj"; index=2), 1, elts, Proj2mat),
        (OpName("StandardBasis"; index=(1, 2)), 1, elts, StandardBasis12mat),
      )
        @test nsites(o) == nbits
        for arraytype in (AbstractArray, AbstractMatrix, Array, Matrix)
          for elt in elts
            ts = ntuple(Returns(t), nbits)
            lens = ntuple(Returns(len), nbits)
            for domain in (ts, (ts,), lens, (lens,))
              @test arraytype(o, domain...) ≈ ref
              @test arraytype{elt}(o, domain...) ≈ ref
              @test eltype(arraytype{elt}(o, domain...)) === elt
            end
          end
        end
      end
    end
  end
  @testset "op parsing" begin
    @test Matrix(opexpr("X * Y")) == op("X") * op("Y")
    @test op("X * Y") == op("X") * op("Y")
    @test op("X * Y + Z") == op("X") * op("Y") + op("Z")
    @test op("X * Y + 2 * Z") == op("X") * op("Y") + 2 * op("Z")
    @test op("exp(im * (X * Y + 2 * Z))") == exp(im * (op("X") * op("Y") + 2 * op("Z")))
    @test op("exp(im * (X ⊗ Y + Z ⊗ Z))") ==
      exp(im * (kron(op("X"), op("Y")) + kron(op("Z"), op("Z"))))
    @test op("Ry{θ=π/2}") == op("Ry"; θ=π / 2)
    # Awkward parsing corner cases.
    @test op("S+") == Matrix(OpName("S+"))
    @test op("S-") == Matrix(OpName("S-"))
    @test op("S+ + S-") == Matrix(OpName("S+") + OpName("S-"))
    @test op("S+ - S-") == Matrix(OpName("S+") - OpName("S-"))
    @test op("a†") == Matrix(OpName("a†"))
    for name in ("c↑", "c†↑", "c↓", "c†↓")
      @test op(name, SiteType("Electron")) == Matrix(OpName(name), SiteType("Electron"))
    end
  end
  @testset "state" begin
    @test state(1) == [1, 0]
    @test state("0") == [1, 0]
    @test state(2) == [0, 1]
    @test state("1") == [0, 1]
    @test state(1, 3) == [1, 0, 0]
    @test state("0", 3) == [1, 0, 0]
    @test state(2, 3) == [0, 1, 0]
    @test state("1", 3) == [0, 1, 0]
    @test state(3, 3) == [0, 0, 1]
    @test state("2", 3) == [0, 0, 1]

    @test state("|0⟩ + 2|+⟩") == state("0") + 2 * state("+")
    @test state("|0⟩ ⊗ |+⟩") == kron(state("0"), state("+"))
  end
end
