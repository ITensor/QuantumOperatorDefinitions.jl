# # ITensorQuantumOperatorDefinitions.jl
# 
# [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://ITensor.github.io/ITensorQuantumOperatorDefinitions.jl/stable/)
# [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ITensor.github.io/ITensorQuantumOperatorDefinitions.jl/dev/)
# [![Build Status](https://github.com/ITensor/ITensorQuantumOperatorDefinitions.jl/actions/workflows/Tests.yml/badge.svg?branch=main)](https://github.com/ITensor/ITensorQuantumOperatorDefinitions.jl/actions/workflows/Tests.yml?query=branch%3Amain)
# [![Coverage](https://codecov.io/gh/ITensor/ITensorQuantumOperatorDefinitions.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/ITensor/ITensorQuantumOperatorDefinitions.jl)
# [![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
# [![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

# ## Installation instructions

# This package resides in the `ITensor/ITensorRegistry` local registry.
# In order to install, simply add that registry through your package manager.
# This step is only required once.
#=
```julia
julia> using Pkg: Pkg

julia> Pkg.Registry.add(url="https://github.com/ITensor/ITensorRegistry")
```
=#
# or:
#=
```julia
julia> Pkg.Registry.add(url="git@github.com:ITensor/ITensorRegistry.git")
```
=#
# if you want to use SSH credentials, which can make it so you don't have to enter your Github ursername and password when registering packages.

# Then, the package can be added as usual through the package manager:

#=
```julia
julia> Pkg.add("ITensorQuantumOperatorDefinitions")
```
=#

# ## Examples

using ITensorQuantumOperatorDefinitions: ITensorQuantumOperatorDefinitions as Ops

using ITensorBase: ITensor, Index, tags
using ITensorQuantumOperatorDefinitions:
  OpName, SiteType, StateName, ⊗, controlled, expand, op, siteind, siteinds, state
using LinearAlgebra: Diagonal
using Test: @test

@test length(SiteType("Qubit")) == 2
@test size(SiteType("Qubit")) == (2,)
@test size(SiteType("Qubit"), 1) == 2
@test axes(SiteType("Qubit")) == (Base.OneTo(2),)
@test axes(SiteType("Qubit"), 1) == Base.OneTo(2)

# TODO: Delete.
## @test Integer(StateName("0"), SiteType("Qubit")) === 1
## @test Integer(StateName("0")) == 1
## @test Integer(StateName("1"), SiteType("Qubit")) === 2
## @test Integer(StateName("1")) == 2
## @test Int(StateName("0"), SiteType("Qubit")) === 1
## @test Int(StateName("1"), SiteType("Qubit")) === 2
## @test Int32(StateName("0"), SiteType("Qubit")) === Int32(1)
## @test Int32(StateName("1"), SiteType("Qubit")) === Int32(2)
## 
## @test Integer(StateName("Up"), SiteType("Qubit")) === 1
## @test Integer(StateName("Dn"), SiteType("Qubit")) === 2
## @test Int(StateName("Up"), SiteType("Qubit")) === 1
## @test Int(StateName("Dn"), SiteType("Qubit")) === 2
## @test Int32(StateName("Up"), SiteType("Qubit")) === Int32(1)
## @test Int32(StateName("Dn"), SiteType("Qubit")) === Int32(2)

@test AbstractArray(StateName("0"), SiteType("Qubit")) == [1, 0]
@test AbstractArray(StateName("1"), SiteType("Qubit")) == [0, 1]
@test AbstractArray{Float32}(StateName("0"), SiteType("Qubit")) == Float32[1, 0]
@test AbstractArray{Float32}(StateName("1"), SiteType("Qubit")) == Float32[0, 1]
@test Vector{Float32}(StateName("0"), SiteType("Qubit")) == Float32[1, 0]
@test Vector{Float32}(StateName("1"), SiteType("Qubit")) == Float32[0, 1]

@test AbstractArray(StateName("Up"), SiteType("Qubit")) == [1, 0]
@test AbstractArray(StateName("Dn"), SiteType("Qubit")) == [0, 1]

@test Matrix(OpName("X"), SiteType("Qubit")) == [0 1; 1 0]
@test Matrix(OpName("σx"), SiteType("Qubit")) == [0 1; 1 0]
@test Matrix(OpName("σ1"), SiteType("Qubit")) == [0 1; 1 0]
@test Matrix(OpName("Z"), SiteType("Qubit")) == [1 0; 0 -1]

@test Matrix(OpName("Rx"; θ=π), SiteType("Qubit")) ≈ [0 -im; -im 0]

## TODO: Delete.
##@test Matrix(OpName("Rx"; θ=π)) ≈ [0 -im; -im 0]

@test Array{<:Any,4}(OpName("CNOT"), (SiteType("Qubit"), SiteType("Qubit"))) ==
  [1; 0;; 0; 0;;; 0; 1;; 0; 0;;;; 0; 0;; 0; 1;;; 0; 0;; 1; 0]

# TODO: Support:
# `AbstractArray(OpName("CNOT"), (2, 2))`?

@test Array(OpName("CNOT"), (SiteType("Qubit"), SiteType("Qubit"))) ==
  [1 0 0 0; 0 1 0 0; 0 0 0 1; 0 0 1 0]

# TODO: Should we allow this?
# @test Array(OpName("CNOT"), (SiteType("Qubit"), SiteType("Qudit"; length=2))) == [1 0 0 0; 0 1 0 0; 0 0 0 1; 0 0 1 0]

@test AbstractArray(OpName("I"), SiteType("Qudit"; length=4)) == Diagonal(trues(4))
@test AbstractArray(OpName("Id"), SiteType("Qudit"; length=4)) == Diagonal(trues(4))

@test Matrix(exp(-im * π / 4 * kron(OpName("X"), OpName("X")))) ≈
  Matrix(OpName("RXX"; θ=π / 2))
@test Matrix(exp(-im * π / 4 * kron(OpName("Y"), OpName("Y")))) ≈
  Matrix(OpName("RYY"; θ=π / 2))
@test Matrix(exp(-im * π / 4 * kron(OpName("Z"), OpName("Z")))) ≈
  Matrix(OpName("RZZ"; θ=π / 2))

# TODO: This is broken, investigate.
# @test Matrix(exp(-im * π/4 * kron(OpName("X"), OpName("Y")))) ≈ Matrix(OpName("RXY"; θ=π/2))

@test siteind("Qubit") isa Index
@test Int(length(siteind("Qubit"))) == 2
@test "Qubit" in tags(siteind("Qubit"))
@test siteinds("Qubit", 4) isa Vector{<:Index}
@test length(siteinds("Qubit", 4)) == 4
@test all(s -> "Qubit" in tags(s), siteinds("Qubit", 4))

I, X, Y, Z = OpName.(("I", "X", "Y", "Z"))
paulis = (I, X, Y, Z)

M = randn(ComplexF64, (2, 2))
c = expand(M, Matrix.(paulis))
M′ = Matrix(sum(c .* paulis))
@test M ≈ M′

paulis2 = vec(splat(kron).(Iterators.product(paulis, paulis)))
M2 = randn(ComplexF64, (4, 4))
c2 = expand(M2, Matrix.(paulis2))
M2′ = Matrix(sum(c2 .* paulis2))
@test M2 ≈ M2′

@test AbstractArray(I, (SiteType("Qubit"), SiteType("Qudit"; length=3))) ==
  Diagonal(trues(6))
@test AbstractArray{<:Any,4}(I, (SiteType("Qubit"), SiteType("Qudit"; length=3))) ==
  reshape(Diagonal(trues(6)), (2, 3, 2, 3))

s1, s2 = Index.((2, 2), "Qubit")
# TODO: Define.
## @test ITensor(OpName("Rx"; θ=π), s1) ≈ ITensor([0 -im; -im 0], (s1', s1))
# Specify just the domain.
## ITensor(OpName("CNOT"), (s1, s2))
# TODO: Allow specifying codomain and domain.
# ITensor(OpName("CNOT"), (s1', s2'), dag.((s1, s2)))
# TODO: Allow specifying the array type.
# ITensor(Array{Float32}, OpName("CNOT"), (s1', s2'), dag.((s1, s2)))
# TODO: Allow specifying the eltype.
# ITensor(Float32, OpName("CNOT"), (s1', s2'), dag.((s1, s2)))

## @test val(s, "Up") == 1
## @test val(s, "Dn") == 2
## @test state("Up", s) == ITensor([1, 0], (s,))
## @test state("Dn", s) == ITensor([0, 1], (s,))
## @test op("X", s) == ITensor([0 1; 1 0], (s', s))
## @test op("Z", s) == ITensor([1 0; 0 -1], (s', s))
