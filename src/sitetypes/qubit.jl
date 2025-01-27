using LinearAlgebra: I

alias(::SiteType"S=1/2") = SiteType"Qubit"()
alias(::SiteType"S=½") = SiteType"Qubit"()
alias(::SiteType"SpinHalf=1/2") = SiteType"Qubit"()

Base.length(::SiteType"Qubit") = 2

# `eigvecs(Z)`
# (::StateName"0", ::Tuple{SiteType"Qubit"}) = [1, 0]

@state_alias "Up" "0"
@state_alias "↑" "0"
@state_alias "Z+" "0"
@state_alias "Zp" "0"

# (::StateName"1", ::Tuple{SiteType"Qubit"}) = [0, 1]

@state_alias "↓" "1"
@state_alias "Dn" "1"
@state_alias "Z-" "1"
@state_alias "Zm" "1"

# `eigvecs(X)`
alias(::StateName"+") = (StateName"0"() + StateName"1"()) / √2
@state_alias "X+" "+"
@state_alias "Xp" "+"

alias(::StateName"-") = (StateName"0"() - StateName"1"()) / √2
@state_alias "X-" "-"
@state_alias "Xm" "-"

# `eigvecs(Y)`
alias(::StateName"i") = (StateName"0"() + im * StateName"1"()) / √2
@state_alias "Y+" "i"
@state_alias "Yp" "i"

alias(::StateName"-i") = (StateName"0"() - im * StateName"1"()) / √2
@state_alias "Y-" "-i"
@state_alias "Ym" "-i"

# SIC-POVMs
(::StateName"Tetra0")(::SiteType"Qubit") = [
  1
  0
]
(::StateName"Tetra2")(::SiteType"Qubit") = [
  1 / √3
  √2 / √3
]
(::StateName"Tetra3")(::SiteType"Qubit") = [
  1 / √3
  √2 / √3 * exp(im * 2π / 3)
]
(::StateName"Tetra4")(::SiteType"Qubit") = [
  1 / √3
  √2 / √3 * exp(im * 4π / 3)
]

# TODO: Define as `(I + σᶻ) / 2`?
alias(::OpName"ProjUp") = OpName"Proj"(; index=1)
@op_alias "projUp" "ProjUp"
@op_alias "Proj↑" "ProjUp"
@op_alias "proj↑" "ProjUp"
@op_alias "Proj0" "ProjUp"
@op_alias "proj0" "ProjUp"

# TODO: Define as `σ⁺ * σ⁻`?
# TODO: Define as `(I - σᶻ) / 2`?
alias(::OpName"ProjDn") = OpName"Proj"(; index=2)
@op_alias "projDn" "ProjDn"
@op_alias "Proj↓" "ProjDn"
@op_alias "proj↓" "ProjDn"
@op_alias "Proj1" "ProjDn"
@op_alias "proj1" "ProjDn"

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
# https://docs.quantum.ibm.com/api/qiskit/qiskit.circuit.library.UGate
function Base.AbstractArray(n::OpName"Rn", ::Tuple{SiteType"Qubit"})
  return [
    cos(n.θ / 2) -exp(im * n.λ)*sin(n.θ / 2)
    exp(im * n.ϕ)*sin(n.θ / 2) exp(im * (n.ϕ + n.λ))*cos(n.θ / 2)
  ]
end
@op_alias "Rn̂" "Rn"

# TODO: Generalize to `"Qudit"` and other SiteTypes.
# https://docs.quantum.ibm.com/api/qiskit/qiskit.circuit.library.UCGate
nsites(n::OpName"Controlled") = get(params(n), :ncontrol, 1) + nsites(n.arg)
function Base.AbstractArray(n::OpName"Controlled", ts::Tuple{Vararg{SiteType"Qubit"}})
  # Number of target qubits.
  nt = nsites(n.arg)
  # Number of control qubits.
  nc = get(params(n), :ncontrol, length(ts) - nt)
  @assert length(ts) == nc + nt
  return [
    I(2^nc) falses(2^nc, 2^nt)
    falses(2^nt, 2^nc) AbstractArray(n.arg, ts[(nc + 1):end])
  ]
end
@op_alias "CNOT" "Controlled" op = OpName"X"()
@op_alias "CX" "Controlled" op = OpName"X"()
@op_alias "CY" "Controlled" op = OpName"Y"()
@op_alias "CZ" "Controlled" op = OpName"Z"()
function alias(n::OpName"CPhase")
  return controlled(OpName"Phase"(; params(n)...))
end
@op_alias "CPHASE" "CPhase"
@op_alias "Cphase" "CPhase"
function alias(n::OpName"CRx")
  return controlled(OpName"Rx"(; params(n)...))
end
@op_alias "CRX" "CRx"
function alias(::OpName"CRy")
  return controlled(OpName"Ry"(; params(n)...))
end
@op_alias "CRY" "CRy"
function alias(::OpName"CRz")
  return controlled(OpName"Rz"(; params(n)...))
end
@op_alias "CRZ" "CRz"
function alias(::OpName"CRn")
  return controlled(; arg=OpName"Rn"(; params(n)...))
end
@op_alias "CRn̂" "CRn"

@op_alias "CCNOT" "Controlled" ncontrol = 2 op = OpName"X"()
@op_alias "Toffoli" "CCNOT"
@op_alias "CCX" "CCNOT"
@op_alias "TOFF" "CCNOT"

@op_alias "CSWAP" "Controlled" ncontrol = 2 op = OpName"SWAP"()
@op_alias "Fredkin" "CSWAP"
@op_alias "CSwap" "CSWAP"
@op_alias "CS" "CSWAP"

@op_alias "CCCNOT" "Controlled" ncontrol = 3 op = OpName"X"()
