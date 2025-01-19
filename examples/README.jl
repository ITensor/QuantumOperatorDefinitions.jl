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

using ITensorBase: ITensor, Index, tags
using ITensorQuantumOperatorDefinitions:
  OpName, SiteType, StateName, ValName, op, siteind, siteinds, state, val
using Test: @test

# States and operators as Julia arrays
@test val(ValName("Up"), SiteType("S=1/2")) == 1
@test val(ValName("Dn"), SiteType("S=1/2")) == 2
@test state(StateName("Up"), SiteType("S=1/2")) == [1, 0]
@test state(StateName("Dn"), SiteType("S=1/2")) == [0, 1]
@test op(OpName("X"), SiteType("S=1/2")) == [0 1; 1 0]
@test op(OpName("Z"), SiteType("S=1/2")) == [1 0; 0 -1]

# Index constructors
@test siteind("S=1/2") isa Index
@test Int(length(siteind("S=1/2"))) == 2
@test "S=1/2" in tags(siteind("S=1/2"))
@test siteinds("S=1/2", 4) isa Vector{<:Index}
@test length(siteinds("S=1/2", 4)) == 4
@test all(s -> "S=1/2" in tags(s), siteinds("S=1/2", 4))

# States and operators as ITensors
s = Index(2, "S=1/2")
@test val(s, "Up") == 1
@test val(s, "Dn") == 2
@test state("Up", s) == ITensor([1, 0], (s,))
@test state("Dn", s) == ITensor([0, 1], (s,))
@test op("X", s) == ITensor([0 1; 1 0], (s', s))
@test op("Z", s) == ITensor([1 0; 0 -1], (s', s))
