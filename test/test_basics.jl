using QuantumOperatorDefinitions: OpName, SiteType, ⊗, expand, op, opexpr, state, nsites
using LinearAlgebra: Diagonal, I
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
        reshape([1 0 0 0; 0 0 1 0; 0 1 0 0; 0 0 0 1], (2, 2, 2, 2)),
        reshape([1 0 0 0; 0 0 im 0; 0 im 0 0; 0 0 0 1], (2, 2, 2, 2)),
        (_, θ) -> reshape(
          [
            cos(θ / 2) 0 0 -im*sin(θ / 2)
            0 cos(θ / 2) -im*sin(θ / 2) 0
            0 -im*sin(θ / 2) cos(θ / 2) 0
            -im*sin(θ / 2) 0 0 cos(θ / 2)
          ],
          (2, 2, 2, 2),
        ),
        (_, θ) -> reshape(
          [
            cos(θ / 2) 0 0 im*sin(θ / 2)
            0 cos(θ / 2) -im*sin(θ / 2) 0
            0 -im*sin(θ / 2) cos(θ / 2) 0
            im*sin(θ / 2) 0 0 cos(θ / 2)
          ],
          (2, 2, 2, 2),
        ),
        (_, θ) -> reshape(
          Diagonal([exp(-im * θ / 2), exp(im * θ / 2), exp(im * θ / 2), exp(-im * θ / 2)]),
          (2, 2, 2, 2),
        ),
        [1 0; 0 0],
        [0 0; 0 1],
        [0 1; 0 0],
      ),
      (
        SiteType("Qudit"; dim=3),
        3,
        √2 * [0 1 0; 1 0 1; 0 1 0],
        √2 * [0 -im 0; im 0 -im; 0 im 0],
        2 * [1 0 0; 0 0 0; 0 0 -1],
        [0 0 0; 0 1 0; 0 0 2],
        reshape(
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
          (3, 3, 3, 3),
        ),
        reshape(
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
          (3, 3, 3, 3),
        ),
        (O, θ) -> reshape(exp(-im * (θ / 2) * kron(O, O)), (3, 3, 3, 3)),
        (O, θ) -> reshape(exp(-im * (θ / 2) * kron(O, O)), (3, 3, 3, 3)),
        (O, θ) -> reshape(exp(-im * (θ / 2) * kron(O, O)), (3, 3, 3, 3)),
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
        # (OpName("√SWAP"), 2, complex_elts, √SWAPmat),
        (OpName("iSWAP"), 2, complex_elts, iSWAPmat),
        # (OpName("√iSWAP"), 2, complex_elts, √iSWAPmat),
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
        for arraytype in (AbstractArray, Array)
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
    @test op("exp(im * (X ⊗ Y + Z ⊗ Z))") == permutedims(
      reshape(exp(im * (kron(op("X"), op("Y")) + kron(op("Z"), op("Z")))), (2, 2, 2, 2)),
      (2, 1, 4, 3),
    )
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
  @testset "Random unitary" begin
    U = op("RandomUnitary")
    @test eltype(U) === Complex{Float64}
    @test U * U' ≈ I(2)

    U = op("RandomUnitary"; eltype=Float32)
    @test eltype(U) === Float32
    @test U * U' ≈ I(2)

    U = op("RandomUnitary", 3)
    @test eltype(U) === Complex{Float64}
    @test U * U' ≈ I(3)
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
    @test state("|0⟩ ⊗ |+⟩") ==
      permutedims(reshape(kron(state("0"), state("+")), (2, 2)), (2, 1))
  end
  @testset "Ranges" begin
    @test AbstractUnitRange(SiteType("S=1/2")) == Base.OneTo(2)
    @test UnitRange{Int32}(SiteType("S=1/2")) == Base.OneTo(2)
    @test UnitRange{Int32}(SiteType("S=1/2")) isa UnitRange{Int32}
    @test AbstractUnitRange(SiteType("Qudit"; dim=3)) == Base.OneTo(3)
    @test UnitRange{Int32}(SiteType("Qudit"; dim=3)) == Base.OneTo(3)
    @test UnitRange{Int32}(SiteType("Qudit"; dim=3)) isa UnitRange{Int32}

    @test op("X", 2) == op("X", Base.OneTo(2))
    @test op("X", 3) == op("X", Base.OneTo(3))
  end
  @testset "Electron/tJ" begin
    for (ns, x) in (
      (("0", "Emp"), [1, 0, 0, 0]),
      (("↑", "Up"), [0, 1, 0, 0]),
      (("↓", "Dn"), [0, 0, 1, 0]),
      (("↑↓", "UpDn"), [0, 0, 0, 1]),
    )
      for n in ns
        @test state(n, SiteType("Electron")) == x
        @test state(n, SiteType("tJ")) == x[1:3]
      end
    end
    for (ns, x) in (
      (("n↑", "Nup"), [0 0 0 0; 0 1 0 0; 0 0 0 0; 0 0 0 1]),
      (("n↓", "Ndn"), [0 0 0 0; 0 0 0 0; 0 0 1 0; 0 0 0 1]),
      (("n↑↓", "Nupdn"), [0 0 0 0; 0 0 0 0; 0 0 0 0; 0 0 0 1]),
      (("ntot", "Ntot"), [0 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 2]),
      (("c↑", "Cup"), [0 1 0 0; 0 0 0 0; 0 0 0 1; 0 0 0 0]),
      (("Sx",), [0 0 0 0; 0 0 1/2 0; 0 1/2 0 0; 0 0 0 0]),
      # TODO: Add more tests.
    )
      for n in ns
        @test op(n, SiteType("Electron")) == x
        @test op(n, SiteType("tJ")) == x[1:3, 1:3]
      end
    end
  end
  @testset "Boson and spin" begin
    for t in (SiteType("Qudit"; dim=3), SiteType("Boson"; dim=3), SiteType("S"; spin=1))
      @test length(t) == 3
      @test op("X", t) == op("X", 3)
    end

    for t in (SiteType("S=1"), SiteType("SpinOne"))
      for (ns, x) in (
        (("Z+", "↑", "Up"), [1, 0, 0]),
        (("Z0", "0"), [0, 1, 0]),
        (("Z-", "↓", "Dn"), [0, 0, 1]),
        (("X+",), [1 / 2, 1 / sqrt(2), 1 / 2]),
        (("X0",), [-1 / sqrt(2), 0, 1 / sqrt(2)]),
        (("X-",), [1 / 2, -1 / sqrt(2), 1 / 2]),
        (("Y+",), [-1 / 2, -im / sqrt(2), 1 / 2]),
        (("Y0",), [1 / sqrt(2), 0, 1 / sqrt(2)]),
        (("Y-",), [-1 / 2, im / sqrt(2), 1 / 2]),
      )
        for n in ns
          @test state(n, t) ≈ x
        end
      end
    end

    # Check they are eigenvalues
    (λ⁺, λ⁰, λ⁻) = (2, 0, -2)
    for t in (SiteType("S=1"), SiteType("SpinOne"))
      for n in ("X", "Y", "Z")
        @test op(n, t) * state("$(n)+", t) ≈ λ⁺ * state("$(n)+", t) atol = eps()
        @test op(n, t) * state("$(n)0", t) ≈ λ⁰ * state("$(n)0", t) atol = eps()
        @test op(n, t) * state("$(n)-", t) ≈ λ⁻ * state("$(n)-", t) atol = eps()
      end
    end
  end
end
