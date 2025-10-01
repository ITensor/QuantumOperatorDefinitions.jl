using LinearAlgebra: I

alias(::SiteType"S=1/2") = SiteType"Qubit"()
alias(::SiteType"S=½") = SiteType"Qubit"()
alias(::SiteType"SpinHalf=1/2") = SiteType"Qubit"()

Base.length(::SiteType"Qubit") = 2

# Avoid aliases since these aren't generic
# to Qudits/higher spin.
(::StateName"Z+")(::SiteType"Qubit") = StateName"0"()(2)
(::StateName"Zp")(domain::SiteType"Qubit") = StateName"Z+"()(domain)
(::StateName"↑")(domain::SiteType"Qubit") = StateName"Z+"()(domain)
(::StateName"Up")(domain::SiteType"Qubit") = StateName"Z+"()(domain)
(::StateName"Emp")(domain::SiteType"Qubit") = StateName"Z+"()(domain)

# Avoid aliases since these aren't generic
# to Qudits/higher spin.
(::StateName"Z-")(::SiteType"Qubit") = StateName"1"()(2)
(::StateName"Zm")(domain::SiteType"Qubit") = StateName"Z-"()(domain)
(::StateName"↓")(domain::SiteType"Qubit") = StateName"Z-"()(domain)
(::StateName"Dn")(domain::SiteType"Qubit") = StateName"Z-"()(domain)
(::StateName"Occ")(domain::SiteType"Qubit") = StateName"Z-"()(domain)

# `eigvecs(X)`
(::StateName"X+")(::SiteType"Qubit") = ((StateName"0"() + StateName"1"()) / √2)(2)
(::StateName"Xp")(domain::SiteType"Qubit") = StateName"X+"()(domain)
(::StateName"+")(domain::SiteType"Qubit") = StateName"X+"()(domain)

(::StateName"X-")(::SiteType"Qubit") = ((StateName"0"() - StateName"1"()) / √2)(2)
(::StateName"Xm")(domain::SiteType"Qubit") = StateName"X-"()(domain)
(::StateName"-")(domain::SiteType"Qubit") = StateName"X-"()(domain)

# `eigvecs(Y)`
(::StateName"Y+")(::SiteType"Qubit") = ((StateName"0"() + im * StateName"1"()) / √2)(2)
(::StateName"Yp")(domain::SiteType"Qubit") = StateName"Y+"()(domain)
(::StateName"i")(domain::SiteType"Qubit") = StateName"Y+"()(domain)

(::StateName"Y-")(::SiteType"Qubit") = ((StateName"0"() - im * StateName"1"()) / √2)(2)
(::StateName"Ym")(domain::SiteType"Qubit") = StateName"Y-"()(domain)
(::StateName"-i")(domain::SiteType"Qubit") = StateName"Y-"()(domain)

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
(::OpName"ProjUp")(::SiteType"Qubit") = OpName"Proj"(; index = 1)(2)
(::OpName"projUp")(domain::SiteType"Qubit") = OpName"ProjUp"()(domain)
(::OpName"Proj↑")(domain::SiteType"Qubit") = OpName"ProjUp"()(domain)
(::OpName"proj↑")(domain::SiteType"Qubit") = OpName"ProjUp"()(domain)
(::OpName"Proj0")(domain::SiteType"Qubit") = OpName"ProjUp"()(domain)
(::OpName"proj0")(domain::SiteType"Qubit") = OpName"ProjUp"()(domain)

# TODO: Define as `σ⁺ * σ⁻`?
# TODO: Define as `(I - σᶻ) / 2`?
(::OpName"ProjDn")(::SiteType"Qubit") = OpName"Proj"(; index = 2)(2)
(::OpName"projDn")(domain::SiteType"Qubit") = OpName"ProjDn"()(domain)
(::OpName"Proj↓")(domain::SiteType"Qubit") = OpName"ProjDn"()(domain)
(::OpName"proj↓")(domain::SiteType"Qubit") = OpName"ProjDn"()(domain)
(::OpName"Proj1")(domain::SiteType"Qubit") = OpName"ProjDn"()(domain)
(::OpName"proj1")(domain::SiteType"Qubit") = OpName"ProjDn"()(domain)

## TODO: Bring this back, decide on names and angle conventions.
## # Related to rotation `"Rn"` around generic axis n̂:
## # exp(-im * n.θ / 2 * n̂ ⋅ σ⃗)
## #=
## TODO: Define R-gate when `λ == -ϕ`, i.e.:
## ```julia
## function Base.AbstractArray(n::OpName"R", ::Tuple{SiteType"Qubit"})
##   return [
##     cos(n.θ / 2) -exp(-im * n.ϕ)*sin(n.θ / 2)
##     exp(im * n.ϕ)*sin(n.θ / 2) cos(n.θ / 2)
##   ]
## end
## ```
## or:
## ```julia
## alias(n::OpName"R") = OpName"Rn"(; θ=n.θ, ϕ=n.ϕ, λ=-n.ϕ)
## =#
## # https://docs.quantum.ibm.com/api/qiskit/qiskit.circuit.library.UGate
## # TODO: Generalize to `"Qudit"`, see:
## # https://quantumcomputing.stackexchange.com/questions/16251/how-does-a-general-rotation-r-hatn-theta-related-to-u-3-gate
## # https://quantumcomputing.stackexchange.com/questions/4249/decomposition-of-an-arbitrary-1-qubit-gate-into-a-specific-gateset
## # https://en.wikipedia.org/wiki/List_of_quantum_logic_gates#Other_named_gates
## # https://en.wikipedia.org/wiki/Spin_(physics)#Higher_spins
## # https://qudev.phys.ethz.ch/static/content/courses/QSIT07/presentations/Schmassmann.pdf
## # http://theory.caltech.edu/~preskill/ph219/chap5_15.pdf
## # https://almuhammadi.com/sultan/books_2020/Nielsen_Chuang.pdf (Chapter 4)
## function (n::OpName"GeneralRotation")(::SiteType"Qubit")
##   return [
##     cos(n.θ / 2) -exp(im * n.λ)*sin(n.θ / 2)
##     exp(im * n.ϕ)*sin(n.θ / 2) exp(im * (n.ϕ + n.λ))*cos(n.θ / 2)
##   ]
## end
