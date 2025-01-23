using LinearAlgebra: I

Base.length(::SiteType"Qubit") = 2

# `eigvecs(Z)`
Base.AbstractArray(::StateName"0", ::Tuple{SiteType"Qubit"}) = [1, 0]
Base.AbstractArray(::StateName"1", ::Tuple{SiteType"Qubit"}) = [0, 1]
@state_alias "Up" "0"
@state_alias "↑" "0"
@state_alias "Z+" "0"
@state_alias "Zp" "0"
@state_alias "↓" "1"
@state_alias "Dn" "1"
@state_alias "Z-" "1"
@state_alias "Zm" "1"

# `eigvecs(X)`
Base.AbstractArray(::StateName"+", ::Tuple{SiteType"Qubit"}) = [1, 1] / √2
Base.AbstractArray(::StateName"-", ::Tuple{SiteType"Qubit"}) = [1, -1] / √2
@state_alias "X+" "+"
@state_alias "Xp" "+"
@state_alias "X-" "-"
@state_alias "Xm" "-"

# `eigvecs(Y)`
Base.AbstractArray(::StateName"i", ::Tuple{SiteType"Qubit"}) = [1, im] / √2
Base.AbstractArray(::StateName"-i", ::Tuple{SiteType"Qubit"}) = [1, -im] / √2
@state_alias "Y+" "i"
@state_alias "Yp" "i"
@state_alias "Y-" "-i"
@state_alias "Ym" "-i"

# SIC-POVMs
@state_alias "Tetra1" "0"
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

# TODO: Write as `(I + σᶻ) / 2`?
Base.AbstractArray(::OpName"ProjUp", ::Tuple{SiteType"Qubit"}) = [
  1 0
  0 0
]
@op_alias "projUp" "ProjUp"
@op_alias "Proj↑" "ProjUp"
@op_alias "proj↑" "ProjUp"
@op_alias "Proj0" "ProjUp"
@op_alias "proj0" "ProjUp"

# TODO: Define as `σ⁺ * σ−`?
# TODO: Write as `(I - σᶻ) / 2`?
Base.AbstractArray(::OpName"ProjDn", ::Tuple{SiteType"Qubit"}) = [
  0 0
  0 1
]
@op_alias "projDn" "ProjDn"
@op_alias "Proj↓" "ProjDn"
@op_alias "proj↓" "ProjDn"
@op_alias "Proj1" "ProjDn"
@op_alias "proj1" "ProjDn"

# TODO: Determine a general spin definition.
# `eigvecs(X)`
Base.AbstractArray(::OpName"H", ::Tuple{SiteType"Qubit"}) = [
  1/√2 1/√2
  1/√2 -1/√2
]

# exp(-im * n.θ / 2 * Z) * exp(im * n.θ)
Base.AbstractArray(n::OpName"Phase", ::Tuple{SiteType"Qubit"}) = [
  1 0
  0 exp(im * n.θ)
]
@op_alias "PHASE" "Phase"
@op_alias "P" "Phase"
@op_alias "π/8" "Phase" θ = π / 4
@op_alias "T" "π/8"
@op_alias "S" "Phase" θ = π / 2

# Rotation around X-axis
# exp(-im * n.θ / 2 * X)
function Base.AbstractArray(n::OpName"Rx", ::Tuple{SiteType"Qubit"})
  return [
    cos(n.θ / 2) -im*sin(n.θ / 2)
    -im*sin(n.θ / 2) cos(n.θ / 2)
  ]
end

# Rotation around Y-axis
# exp(-im * n.θ / 2 * Y)
function Base.AbstractArray(n::OpName"Ry", ::Tuple{SiteType"Qubit"})
  return [
    cos(n.θ / 2) -sin(n.θ / 2)
    sin(n.θ / 2) cos(n.θ / 2)
  ]
end

# Rotation around Z-axis
# exp(-im * n.θ / 2 * Z)
function Base.AbstractArray(n::OpName"Rz", ::Tuple{SiteType"Qubit"})
  return [
    exp(-im * n.θ / 2) 0
    0 exp(im * n.θ / 2)
  ]
end

# Rotation around generic axis n̂
# exp(-im * n.θ / 2 * n̂ ⋅ σ⃗)
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
@op_alias "Rn̂" "Rn"

# TODO: Generalize to `"Qudit"` and other SiteTypes.
nsites(n::OpName"Control") = get(params(n), :ncontrol, 1) + nsites(n.op)
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
@op_alias "CNOT" "Control" op = OpName"X"()
@op_alias "CX" "Control" op = OpName"X"()
@op_alias "CY" "Control" op = OpName"Y"()
@op_alias "CZ" "Control" op = OpName"Z"()
function alias(n::OpName"CPhase")
  return controlled(OpName"Phase"(; params(n)...))
end
@op_alias "CPHASE" "CPhase"
@op_alias "Cphase" "CPhase"
function alias(n::OpName"CRx")
  return controlled(OpName"Rx"(; params(n)...))
end
@op_alias "CRX" "CRx"
function Base.AbstractArray(::OpName"CRy")
  return controlled(OpName"Ry"(; params(n)...))
end
@op_alias "CRY" "CRy"
function Base.AbstractArray(::OpName"CRz")
  return controlled(OpName"Rz"(; params(n)...))
end
@op_alias "CRZ" "CRz"
function Base.AbstractArray(::OpName"CRn")
  return controlled(; op=OpName"Rn"(; params(n)...))
end
@op_alias "CRn̂" "CRn"

@op_alias "CCNOT" "Control" ncontrol = 2 op = OpName"X"()
@op_alias "Toffoli" "CCNOT"
@op_alias "CCX" "CCNOT"
@op_alias "TOFF" "CCNOT"

@op_alias "CSWAP" "Control" ncontrol = 2 op = OpName"SWAP"()
@op_alias "Fredkin" "CSWAP"
@op_alias "CSwap" "CSWAP"
@op_alias "CS" "CSWAP"

@op_alias "CCCNOT" "Control" ncontrol = 3 op = OpName"X"()

# TODO: Generalize to `"Qudit"` and other SiteTypes.
# (I ⊗ I + X ⊗ X + Y ⊗ Y + Z ⊗ Z) / 2
nsites(n::OpName"OpSWAP") = 1 + nsites(n.op)
function Base.AbstractArray(n::OpName"OpSWAP", ts::Tuple{Vararg{SiteType"Qubit"}})
  @assert nsites(n.op) == 1
  return [
    trues(1, 1) falses(1, 2) falses(1, 1)
    falses(2, 1) AbstractArray(n.op, SiteType"Qubit"()) falses(2, 1)
    falses(1, 1) falses(1, 2) trues(1, 1)
  ]
end
@op_alias "SWAP" "OpSWAP" op = OpName"X"()
@op_alias "Swap" "SWAP"
@op_alias "√SWAP" "OpSWAP" op = OpName"√X"()
@op_alias "√Swap" "√SWAP"
@op_alias "iSWAP" "OpSWAP" op = OpName"iX"()
@op_alias "iSwap" "iSWAP"
@op_alias "√iSWAP" "OpSWAP" op = √(OpName"iX"())
@op_alias "√iSwap" "√iSWAP"

# Ising (XX) coupling gate
# exp(-im * θ/2 * X ⊗ X)
# TODO: Define as:
# alias(n::OpName"Rxx") = exp(-im * (n.θ / 2) * OpName"X"() ⊗ OpName"X"())
nsites(::OpName"Rxx") = 2
function Base.AbstractArray(n::OpName"Rxx", t::Tuple{SiteType"Qubit",SiteType"Qubit"})
  return [
    cos(n.θ / 2) 0 0 -im*sin(n.θ / 2)
    0 cos(n.θ / 2) -im*sin(n.θ / 2) 0
    0 -im*sin(n.θ / 2) cos(n.θ / 2) 0
    -im*sin(n.θ / 2) 0 0 cos(n.θ / 2)
  ]
end
@op_alias "RXX" "Rxx"

# Ising (YY) coupling gate
# exp(-im * θ/2 * Y ⊗ Y)
# TODO: Define as:
# alias(n::OpName"Ryy") = exp(-im * (n.θ / 2) * OpName"Y"() ⊗ OpName"Y"())
nsites(::OpName"Ryy") = 2
function Base.AbstractArray(n::OpName"Ryy", ::Tuple{SiteType"Qubit",SiteType"Qubit"})
  return [
    cos(n.θ / 2) 0 0 im*sin(n.θ / 2)
    0 cos(n.θ / 2) -im*sin(n.θ / 2) 0
    0 -im*sin(n.θ / 2) cos(n.θ / 2) 0
    im*sin(n.θ / 2) 0 0 cos(n.θ / 2)
  ]
end
@op_alias "RYY" "Ryy"

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
@op_alias "RZZ" "Rzz"

## TODO: This seems to be broken, investigate.
## # Ising (XY) coupling gate
## # exp(-im * θ/2 * X ⊗ Y)
## alias(n::OpName"Rxy") = OpName("OpSWAP"; op=OpName"Rx"(; θ=n.θ))
## @op_alias "RXY" "Rxy"
