using LinearAlgebra: I

Base.length(::SiteType"Qubit") = 2

Base.AbstractArray(::StateName"0", ::Tuple{SiteType"Qubit"}) = [1, 0]
Base.AbstractArray(::StateName"1", ::Tuple{SiteType"Qubit"}) = [0, 1]
Base.AbstractArray(::StateName"+", ::Tuple{SiteType"Qubit"}) = [1, 1] / √2
Base.AbstractArray(::StateName"-", ::Tuple{SiteType"Qubit"}) = [1, -1] / √2
Base.AbstractArray(::StateName"i", ::Tuple{SiteType"Qubit"}) = [1, im] / √2
Base.AbstractArray(::StateName"-i", ::Tuple{SiteType"Qubit"}) = [1, -im] / √2

# SIC-POVMs
Base.AbstractArray(::StateName"Tetra2", ::Tuple{SiteType"Qubit"}) = [
  1 / √3
  √2 / √3
]
function Base.AbstractArray(::StateName"Tetra3", ::Tuple{SiteType"Qubit"})
  return [
    1 / √3
    √2 / √3 * exp(im * 2π / 3)
  ]
end
function Base.AbstractArray(::StateName"Tetra4", ::Tuple{SiteType"Qubit"})
  return [
    1 / √3
    √2 / √3 * exp(im * 4π / 3)
  ]
end

#
# 1-Qubit gates
#
Base.AbstractArray(::OpName"X", ::Tuple{SiteType"Qubit"}) = [
  0 1
  1 0
]

Base.AbstractArray(::OpName"Y", ::Tuple{SiteType"Qubit"}) = [
  0 -im
  im 0
]

Base.AbstractArray(::OpName"Z", ::Tuple{SiteType"Qubit"}) = [
  1 0
  0 -1
]

Base.AbstractArray(::OpName"S+", ::Tuple{SiteType"Qubit"}) = [
  0 1
  0 0
]
Base.AbstractArray(::OpName"S-", ::Tuple{SiteType"Qubit"}) = [
  0 0
  1 0
]
Base.AbstractArray(::OpName"ProjUp", ::Tuple{SiteType"Qubit"}) = [
  1 0
  0 0
]
Base.AbstractArray(::OpName"ProjDn", ::Tuple{SiteType"Qubit"}) = [
  0 0
  0 1
]

Base.AbstractArray(::OpName"H", ::Tuple{SiteType"Qubit"}) = [
  1/√2 1/√2
  1/√2 -1/√2
]

Base.AbstractArray(n::OpName"Phase", ::Tuple{SiteType"Qubit"}) = [
  1 0
  0 exp(im * n.θ)
]

# Rotation around X-axis
function Base.AbstractArray(n::OpName"Rx", ::Tuple{SiteType"Qubit"})
  return [
    cos(n.θ / 2) -im*sin(n.θ / 2)
    -im*sin(n.θ / 2) cos(n.θ / 2)
  ]
end

# Rotation around Y-axis
function Base.AbstractArray(n::OpName"Ry", ::Tuple{SiteType"Qubit"})
  return [
    cos(n.θ / 2) -sin(n.θ / 2)
    sin(n.θ / 2) cos(n.θ / 2)
  ]
end

# Rotation around Z-axis
function Base.AbstractArray(n::OpName"Rz", ::Tuple{SiteType"Qubit"})
  return [
    exp(-im * n.θ / 2) 0
    0 exp(im * n.θ / 2)
  ]
end

# Rotation around generic axis n̂
#=
TODO: Define R-gate when `λ == -ϕ`, i.e.:
```julia
function Base.AbstractArray(n::OpName"R", ::Tuple{SiteType"Qubit"})
  return [
    cos(n.θ / 2) -exp(-im * n.ϕ)*sin(n.θ / 2)
    exp(im * n.ϕ)*sin(n.θ / 2) cos(n.θ / 2)
  ]
end
```
or:
```julia
alias(n::OpName"R") = OpName"Rn"(; θ=n.θ, ϕ=n.ϕ, λ=-n.ϕ)
=#
function Base.AbstractArray(n::OpName"Rn", ::Tuple{SiteType"Qubit"})
  return [
    cos(n.θ / 2) -exp(im * n.λ)*sin(n.θ / 2)
    exp(im * n.ϕ)*sin(n.θ / 2) exp(im * (n.ϕ + n.λ))*cos(n.θ / 2)
  ]
end

# TODO: Generalize to `"Qudit"` and other SiteTypes.
function Base.AbstractArray(n::OpName"Control", ts::Tuple{Vararg{SiteType"Qubit"}})
  # Number of target qubits.
  nt = nsites(n.op)
  # Number of control qubits.
  nc = get(params(n), :ncontrol, length(ts) - nt)
  @assert length(ts) == nc + nt
  return [
    I(2^nc) falses(2^nc, 2^nt)
    falses(2^nt, 2^nc) AbstractArray(n.op, ts[(nc + 1):end])
  ]
end

function Base.AbstractArray(n::OpName"OpSWAP", ts::Tuple{Vararg{SiteType"Qubit"}})
  @assert nsites(n.op) == 1
  return [
    trues(1, 1) falses(1, 2) falses(1, 1)
    falses(2, 1) AbstractArray(n.op, SiteType"Qubit"()) falses(2, 1)
    falses(1, 1) falses(1, 2) trues(1, 1)
  ]
end

# Ising (XX) coupling gate
# exp(-im * θ/2 * X ⊗ X)
# TODO: Define as:
# alias(n::OpName"Rxx") = exp(-im * (n.θ / 2) * OpName"X"() ⊗ OpName"X"())
function Base.AbstractArray(n::OpName"Rxx", t::Tuple{SiteType"Qubit",SiteType"Qubit"})
  return [
    cos(n.θ / 2) 0 0 -im*sin(n.θ / 2)
    0 cos(n.θ / 2) -im*sin(n.θ / 2) 0
    0 -im*sin(n.θ / 2) cos(n.θ / 2) 0
    -im*sin(n.θ / 2) 0 0 cos(n.θ / 2)
  ]
end

# Ising (YY) coupling gate
# exp(-im * θ/2 * Y ⊗ Y)
# TODO: Define as:
# alias(n::OpName"Ryy") = exp(-im * (n.θ / 2) * OpName"Y"() ⊗ OpName"Y"())
function Base.AbstractArray(n::OpName"Ryy", ::Tuple{SiteType"Qubit",SiteType"Qubit"})
  return [
    cos(n.θ / 2) 0 0 im*sin(n.θ / 2)
    0 cos(n.θ / 2) -im*sin(n.θ / 2) 0
    0 -im*sin(n.θ / 2) cos(n.θ / 2) 0
    im*sin(n.θ / 2) 0 0 cos(n.θ / 2)
  ]
end

# Ising (ZZ) coupling gate
# exp(-im * θ/2 * Z ⊗ Z)
# TODO: Define as:
# alias(n::OpName"Rzz") = exp(-im * (n.θ / 2) * OpName"Z"() ⊗ OpName"Z"())
function Base.AbstractArray(n::OpName"Rzz", ::Tuple{SiteType"Qubit"})
  return [
    exp(-im * n.θ / 2) 0 0 0
    0 exp(im * n.θ / 2) 0 0
    0 0 exp(im * n.θ / 2) 0
    0 0 0 exp(-im * n.θ / 2)
  ]
end
