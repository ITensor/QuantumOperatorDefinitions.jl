using LinearAlgebra: I

alias(::SiteType"S=1/2") = SiteType"Qubit"()
alias(::SiteType"S=½") = SiteType"Qubit"()
alias(::SiteType"SpinHalf=1/2") = SiteType"Qubit"()

Base.length(::SiteType"Qubit") = 2

(::StateName"↑")(::SiteType"Qubit") = StateName"0"()(2)
(::StateName"Up")(::SiteType"Qubit") = StateName"0"()(2)
(::StateName"Z+")(::SiteType"Qubit") = StateName"0"()(2)
(::StateName"Zp")(::SiteType"Qubit") = StateName"0"()(2)
(::StateName"Emp")(::SiteType"Qubit") = StateName"0"()(2)

(::StateName"↓")(::SiteType"Qubit") = StateName"1"()(2)
(::StateName"Dn")(::SiteType"Qubit") = StateName"1"()(2)
(::StateName"Z-")(::SiteType"Qubit") = StateName"1"()(2)
(::StateName"Zm")(::SiteType"Qubit") = StateName"1"()(2)
(::StateName"Occ")(::SiteType"Qubit") = StateName"1"()(2)

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
# TODO: Generalize to `"Qudit"`, see:
# https://quantumcomputing.stackexchange.com/questions/16251/how-does-a-general-rotation-r-hatn-theta-related-to-u-3-gate
# https://quantumcomputing.stackexchange.com/questions/4249/decomposition-of-an-arbitrary-1-qubit-gate-into-a-specific-gateset
# https://en.wikipedia.org/wiki/List_of_quantum_logic_gates#Other_named_gates
# https://en.wikipedia.org/wiki/Spin_(physics)#Higher_spins
function (n::OpName"Rn")(::SiteType"Qubit")
  return [
    cos(n.θ / 2) -exp(im * n.λ)*sin(n.θ / 2)
    exp(im * n.ϕ)*sin(n.θ / 2) exp(im * (n.ϕ + n.λ))*cos(n.θ / 2)
  ]
end
@op_alias "Rn̂" "Rn"
