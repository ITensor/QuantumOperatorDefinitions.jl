# QuantumOperatorDefinitions.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://ITensor.github.io/QuantumOperatorDefinitions.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ITensor.github.io/QuantumOperatorDefinitions.jl/dev/)
[![Build Status](https://github.com/ITensor/QuantumOperatorDefinitions.jl/actions/workflows/Tests.yml/badge.svg?branch=main)](https://github.com/ITensor/QuantumOperatorDefinitions.jl/actions/workflows/Tests.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/ITensor/QuantumOperatorDefinitions.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/ITensor/QuantumOperatorDefinitions.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

## Installation instructions

This package resides in the `ITensor/ITensorRegistry` local registry.
In order to install, simply add that registry through your package manager.
This step is only required once.
```julia
julia> using Pkg: Pkg

julia> Pkg.Registry.add(url="https://github.com/ITensor/ITensorRegistry")
```
or:
```julia
julia> Pkg.Registry.add(url="git@github.com:ITensor/ITensorRegistry.git")
```
if you want to use SSH credentials, which can make it so you don't have to enter your Github ursername and password when registering packages.

Then, the package can be added as usual through the package manager:

```julia
julia> Pkg.add("QuantumOperatorDefinitions")
```

## Examples

````julia
using QuantumOperatorDefinitions:
  OpName, SiteType, StateName, ⊗, controlled, op, state
using LinearAlgebra: Diagonal
using SparseArrays: SparseMatrixCSC, SparseVector
using Test: @test

@test state("0") == [1, 0]
@test state("1") == [0, 1]

@test state(Float32, "0") == [1, 0]
@test eltype(state(Float32, "1")) === Float32

@test Vector(StateName("0")) == [1, 0]
@test Vector(StateName("1")) == [0, 1]

@test Vector{Float32}(StateName("0")) == [1, 0]
@test eltype(Vector{Float32}(StateName("0"))) === Float32

@test state(SparseVector, "0") == [1, 0]
@test state(SparseVector, "0") isa SparseVector

@test state("0", 3) == [1, 0, 0]
@test state("1", 3) == [0, 1, 0]
@test state("2", 3) == [0, 0, 1]

@test Vector(StateName("0"), 3) == [1, 0, 0]
@test Vector(StateName("1"), 3) == [0, 1, 0]
@test Vector(StateName("2"), 3) == [0, 0, 1]

@test op("X") == [0 1; 1 0]
@test op("Y") == [0 -im; im 0]
@test op("Z") == [1 0; 0 -1]

@test op("Z") isa Diagonal

@test op(Float32, "X") == [0 1; 1 0]
@test eltype(op(Float32, "X")) === Float32
@test op(SparseMatrixCSC, "X") == [0 1; 1 0]
@test op(SparseMatrixCSC, "X") isa SparseMatrixCSC

@test Matrix(OpName("X")) == [0 1; 1 0]
@test Matrix(OpName("Y")) == [0 -im; im 0]
@test Matrix(OpName("Z")) == [1 0; 0 -1]

@test Matrix(OpName("Rx"; θ=π / 3)) ≈ [sin(π / 3) -cos(π / 3)*im; -cos(π / 3)*im sin(π / 3)]
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

