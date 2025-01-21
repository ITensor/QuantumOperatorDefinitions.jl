using LinearAlgebra: I

# Qubit
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

Base.AbstractArray(::OpName"iY", ::Tuple{SiteType"Qubit"}) = [
  0 1
  -1 0
]

Base.AbstractArray(::OpName"Z", ::Tuple{SiteType"Qubit"}) = [
  1 0
  0 -1
]

function Base.AbstractArray(::OpName"√NOT", ::Tuple{SiteType"Qubit"})
  return [
    (1 + im)/2 (1 - im)/2
    (1 - im)/2 (1 + im)/2
  ]
end

Base.AbstractArray(::OpName"H", ::Tuple{SiteType"Qubit"}) = [
  1/√2 1/√2
  1/√2 -1/√2
]

# Rϕ with ϕ = π/2
Base.AbstractArray(n::OpName"Phase", ::Tuple{SiteType"Qubit"}) = [
  1 0
  0 exp(im * n.ϕ)
]

## Rϕ with ϕ = π/4
Base.AbstractArray(::OpName"π/8", ::Tuple{SiteType"Qubit"}) = [
  1 0
  0 1 / √2+im / √2
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
function Base.AbstractArray(n::OpName"Rn", ::Tuple{SiteType"Qubit"})
  return [
    cos(n.θ / 2) -exp(im * n.λ)*sin(n.θ / 2)
    exp(im * n.ϕ)*sin(n.θ / 2) exp(im * (n.ϕ + n.λ))*cos(n.θ / 2)
  ]
end

#
# 2-Qubit gates
#
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

# TODO: Define as `::OpName"OpSWAP"(; op=OpName"X"())`.
function Base.AbstractArray(::OpName"SWAP", ::Tuple{SiteType"Qubit"})
  return [
    1 0 0 0
    0 0 1 0
    0 1 0 0
    0 0 0 1
  ]
end
function Base.AbstractArray(::OpName"Swap", t::Tuple{SiteType"Qubit"})
  return Base.AbstractArray("SWAP", t)
end

# TODO: Use this to define `√X`, etc.
function Base.AbstractArray(n::OpName"√", ts::Tuple{Vararg{SiteType}})
  return √(AbstractArray(n.op, ts))
end

# TODO: Define as `alias(::OpName"√SWAP") = OpName"√"(; op=OpName"SWAP")`.
# TODO: Define as `::OpName"OpSWAP"(; op=OpName"√X"())`.
function Base.AbstractArray(::OpName"√SWAP", ::Tuple{SiteType"Qubit"})
  return [
    1 0 0 0
    0 (1 + im)/2 (1 - im)/2 0
    0 (1 - im)/2 (1 + im)/2 0
    0 0 0 1
  ]
end
function Base.AbstractArray(::OpName"√Swap", t::Tuple{SiteType"Qubit"})
  return Base.AbstractArray("√SWAP", t)
end

# TODO: Define as `::OpName"OpSWAP"(; op=OpName"iX"())`.
function Base.AbstractArray(::OpName"iSWAP", t::Tuple{SiteType"Qubit"})
  return [
    1 0 0 0
    0 0 im 0
    0 im 0 0
    0 0 0 1
  ]
end
function Base.AbstractArray(::OpName"iSwap", t::Tuple{SiteType"Qubit"})
  return Base.AbstractArray("iSWAP", t)
end

function Base.AbstractArray(::OpName"√iSWAP", t::Tuple{SiteType"Qubit"})
  return [
    1 0 0 0
    0 1/√2 im/√2 0
    0 im/√2 1/√2 0
    0 0 0 1
  ]
end
function Base.AbstractArray(::OpName"√iSwap", t::Tuple{SiteType"Qubit"})
  return Base.AbstractArray("√iSWAP", t)
end

# Ising (XX) coupling gate
function Base.AbstractArray(::OpName"Rxx", t::Tuple{SiteType"Qubit"}; ϕ::Number)
  return [
    cos(ϕ) 0 0 -im*sin(ϕ)
    0 cos(ϕ) -im*sin(ϕ) 0
    0 -im*sin(ϕ) cos(ϕ) 0
    -im*sin(ϕ) 0 0 cos(ϕ)
  ]
end
function Base.AbstractArray(::OpName"RXX", t::Tuple{SiteType"Qubit"}; kwargs...)
  return Base.AbstractArray("Rxx", t; kwargs...)
end

# Ising (YY) coupling gate
function Base.AbstractArray(::OpName"Ryy", ::Tuple{SiteType"Qubit"}; ϕ::Number)
  return [
    cos(ϕ) 0 0 im*sin(ϕ)
    0 cos(ϕ) -im*sin(ϕ) 0
    0 -im*sin(ϕ) cos(ϕ) 0
    im*sin(ϕ) 0 0 cos(ϕ)
  ]
end
function Base.AbstractArray(::OpName"RYY", t::Tuple{SiteType"Qubit"}; kwargs...)
  return Base.AbstractArray("Ryy", t; kwargs...)
end

# Ising (XY) coupling gate
function Base.AbstractArray(::OpName"Rxy", t::Tuple{SiteType"Qubit"}; ϕ::Number)
  return [
    1 0 0 0
    0 cos(ϕ) -im*sin(ϕ) 0
    0 -im*sin(ϕ) cos(ϕ) 0
    0 0 0 1
  ]
end
function Base.AbstractArray(::OpName"RXY", t::Tuple{SiteType"Qubit"}; kwargs...)
  return Base.AbstractArray("Rxy", t; kwargs...)
end

# Ising (ZZ) coupling gate
function Base.AbstractArray(::OpName"Rzz", ::Tuple{SiteType"Qubit"}; ϕ::Number)
  return [
    exp(-im * ϕ) 0 0 0
    0 exp(im * ϕ) 0 0
    0 0 exp(im * ϕ) 0
    0 0 0 exp(-im * ϕ)
  ]
end
function Base.AbstractArray(::OpName"RZZ", t::Tuple{SiteType"Qubit"}; kwargs...)
  return Base.AbstractArray("Rzz", t; kwargs...)
end

#
# 3-Qubit gates
#

# TODO: Define in terms of `Control`.
function Base.AbstractArray(::OpName"Toffoli", ::Tuple{Vararg{SiteType"Qubit",3}})
  return [
    1 0 0 0 0 0 0 0
    0 1 0 0 0 0 0 0
    0 0 1 0 0 0 0 0
    0 0 0 1 0 0 0 0
    0 0 0 0 1 0 0 0
    0 0 0 0 0 1 0 0
    0 0 0 0 0 0 0 1
    0 0 0 0 0 0 1 0
  ]
end
alias(::OpName"CCNOT") = OpName"Toffoli"()
alias(::OpName"CCX") = OpName"Toffoli"()
alias(::OpName"TOFF") = OpName"Toffoli"()

# TODO: Define in terms of `Control` and `SWAP`.
function Base.AbstractArray(::OpName"Fredkin", ::Tuple{Vararg{SiteType"Qubit",3}})
  return [
    1 0 0 0 0 0 0 0
    0 1 0 0 0 0 0 0
    0 0 1 0 0 0 0 0
    0 0 0 1 0 0 0 0
    0 0 0 0 1 0 0 0
    0 0 0 0 0 0 1 0
    0 0 0 0 0 1 0 0
    0 0 0 0 0 0 0 1
  ]
end
alias(::OpName"CSWAP") = OpName"Fredkin"()
alias(::OpName"CSwap") = OpName"Fredkin"()
alias(::OpName"CS") = OpName"Fredkin"()

#
# 4-Qubit gates
#

# TODO: Define in terms of `Control` and `SWAP`.
function Base.AbstractArray(::OpName"CCCNOT", ts::Tuple{Vararg{SiteType"Qubit",4}})
  return [
    1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0
  ]
end

# spin-full operators
Base.AbstractArray(::OpName"Sz", ::Tuple{SiteType"Qubit"}) = [
  0.5 0.0
  0.0 -0.5
]

Base.AbstractArray(::OpName"S+", ::Tuple{SiteType"Qubit"}) = [
  0 1
  0 0
]
function Base.AbstractArray(on::OpName"S⁺", t::Tuple{SiteType"Qubit"})
  return Base.AbstractArray(alias(on), t)
end
function Base.AbstractArray(on::OpName"Splus", t::Tuple{SiteType"Qubit"})
  return Base.AbstractArray(alias(on), t)
end

Base.AbstractArray(::OpName"S-", ::Tuple{SiteType"Qubit"}) = [
  0 0
  1 0
]
function Base.AbstractArray(on::OpName"S⁻", t::Tuple{SiteType"Qubit"})
  return Base.AbstractArray(alias(on), t)
end
function Base.AbstractArray(on::OpName"Sminus", t::Tuple{SiteType"Qubit"})
  return Base.AbstractArray(alias(on), t)
end

Base.AbstractArray(::OpName"Sx", ::Tuple{SiteType"Qubit"}) = [
  0.0 0.5
  0.5 0.0
]
function Base.AbstractArray(on::OpName"Sˣ", t::Tuple{SiteType"Qubit"})
  return Base.AbstractArray(alias(on), t)
end

Base.AbstractArray(::OpName"iSy", ::Tuple{SiteType"Qubit"}) = [
  0.0 0.5
  -0.5 0.0
]
function Base.AbstractArray(on::OpName"iSʸ", t::Tuple{SiteType"Qubit"})
  return Base.AbstractArray(alias(on), t)
end

Base.AbstractArray(::OpName"Sy", ::Tuple{SiteType"Qubit"}) = [
  0.0 -0.5im
  0.5im 0.0
]
function Base.AbstractArray(on::OpName"Sʸ", t::Tuple{SiteType"Qubit"})
  return Base.AbstractArray(alias(on), t)
end

Base.AbstractArray(::OpName"S2", ::Tuple{SiteType"Qubit"}) = [
  0.75 0.0
  0.0 0.75
]
function Base.AbstractArray(on::OpName"S²", t::Tuple{SiteType"Qubit"})
  return Base.AbstractArray(alias(on), t)
end

Base.AbstractArray(::OpName"ProjUp", ::Tuple{SiteType"Qubit"}) = [
  1 0
  0 0
]
function Base.AbstractArray(on::OpName"projUp", t::Tuple{SiteType"Qubit"})
  return Base.AbstractArray(alias(on), t)
end
function Base.AbstractArray(on::OpName"Proj0", t::Tuple{SiteType"Qubit"})
  return Base.AbstractArray(alias(on), t)
end

Base.AbstractArray(::OpName"ProjDn", ::Tuple{SiteType"Qubit"}) = [
  0 0
  0 1
]
function Base.AbstractArray(on::OpName"projDn", t::Tuple{SiteType"Qubit"})
  return Base.AbstractArray(alias(on), t)
end
function Base.AbstractArray(on::OpName"Proj1", t::Tuple{SiteType"Qubit"})
  return Base.AbstractArray(alias(on), t)
end
