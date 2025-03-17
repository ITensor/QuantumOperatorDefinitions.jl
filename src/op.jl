using LinearAlgebra: diag, qr

struct OpName{Name,Params}
  params::Params
  function OpName{N}(params::NamedTuple) where {N}
    return new{N,typeof(params)}(params)
  end
end
name(::OpName{Name}) where {Name} = Name
params(n::OpName) = getfield(n, :params)
Base.getproperty(n::OpName, name::Symbol) = getfield(params(n), name)
Base.get(t::OpName, name::Symbol, default) = get(params(t), name, default)

OpName{N}(; kwargs...) where {N} = OpName{N}((; kwargs...))

# This compiles operator expressions, such as:
# ```julia
# opexpr("X + Y") == OpName("X") + OpName("Y")
# opexpr("Ry{θ=π/2}") == OpName("Ry"; θ=π/2)
# ```
function opexpr(n::String; kwargs...)
  return state_or_op_expr(OpName, n; kwargs...)
end

# TODO: Should this parse the string?
OpName(s::AbstractString; kwargs...) = OpName{Symbol(s)}(; kwargs...)
OpName(s::Symbol; kwargs...) = OpName{s}(; kwargs...)
# TODO: Should this parse the string?
macro OpName_str(s)
  return :(OpName{$(Expr(:quote, Symbol(s)))})
end

# This version parses. Disabled for now until
# it is written better, there is a compelling
# use case, and the name is decided.
# TODO: Write this in terms of expressions, avoid
# `eval`.
# macro opexpr_str(s)
#   return :(typeof(opexpr($s)))
# end
# macro statexpr_str(s)
#   return :(typeof(stateexpr($s)))
# end

function op_alias_expr(name1, name2, pars...)
  return :(function alias(n::OpName{Symbol($name1)})
    return OpName{Symbol($name2)}(; params(n)..., $(esc.(pars)...))
  end)
end
macro op_alias(name1, name2, pars...)
  return op_alias_expr(name1, name2, pars...)
end

# Generic to `StateName` or `OpName`.
const StateOrOpName = Union{StateName,OpName}
alias(n::StateOrOpName) = n
function (arrtype::Type{<:AbstractArray})(
  n::StateOrOpName, domain::Union{Integer,AbstractUnitRange}...
)
  return arrtype(n, domain)
end
function (arrtype::Type{<:AbstractArray})(n::StateOrOpName, domain::Tuple{Vararg{Integer}})
  return arrtype(n, Base.oneto.(domain))
end
(arrtype::Type{<:AbstractArray})(n::StateOrOpName, ts::SiteType...) = arrtype(n, ts)
function (n::StateOrOpName)(domain...)
  # TODO: Try one alias at a time?
  # TODO: First call `alias(n, domain...)`
  # to allow for aliases specific to certain
  # SiteTypes?
  n′ = alias(n)
  domain′ = alias.(domain)
  if n′ == n && domain′ == domain
    error("Not implemented.")
  end
  return n′(domain′...)
end
# TODO: Decide on this.
function (n::StateOrOpName)()
  return n(ntuple(Returns(default_sitetype()), nsites(n))...)
end
function (arrtype::Type{<:AbstractArray})(n::StateOrOpName)
  return arrtype(n, ntuple(Returns(default_sitetype()), nsites(n)))
end
# `Int(ndims // 2)`, i.e. `ndims_domain`/`ndims_codomain`.
function nsites(n::StateOrOpName)
  n′ = alias(n)
  if n′ == n
    # Default value, assume 1-site operator/state.
    return 1
  end
  return nsites(n′)
end

# TODO: This does some unwanted conversions, like turning
# `Diagonal` dense.
function array(a::AbstractArray, ax::Tuple{Vararg{AbstractUnitRange}})
  return a[ax...]
end

function Base.axes(::OpName, domain::Tuple{Vararg{AbstractUnitRange}})
  return (domain..., domain...)
end
function Base.axes(n::StateOrOpName, domain::Tuple{Vararg{Integer}})
  return axes(n, Base.OneTo.(domain))
end
function Base.axes(n::StateOrOpName, domain::Tuple{Vararg{SiteType}})
  return axes(n, AbstractUnitRange.(domain))
end

## function Base.axes(::OpName"SWAP", domain::Tuple{Vararg{AbstractUnitRange}})
##   return (reverse(domain)..., domain...)
## end

function reversed_sites(n::StateOrOpName, domain)
  return reverse_sites(n, reshape(n(domain...), length.(axes(n, reverse(domain)))))
end
function reverse_sites(n::OpName, a::AbstractArray)
  ndomain = Int(ndims(a)//2)
  perm1 = reverse(ntuple(identity, ndomain))
  perm2 = perm1 .+ ndomain
  perm = (perm1..., perm2...)
  return permutedims(a, perm)
end

function state_or_op_convert(
  n::StateOrOpName,
  arrtype::Type{<:AbstractArray},
  domain::Tuple{Vararg{AbstractUnitRange}},
  a::AbstractArray,
)
  ax = axes(n, domain)
  a′ = reshape(a, length.(ax))
  a′′ = array(a′, ax)
  return convert(arrtype, a′′)
end

function (arrtype::Type{<:AbstractArray})(n::StateOrOpName, domain::Tuple{Vararg{SiteType}})
  domain′ = AbstractUnitRange.(domain)
  return state_or_op_convert(n, arrtype, domain′, reversed_sites(n, domain))
end
function (arrtype::Type{<:AbstractArray})(
  n::StateOrOpName, domain::Tuple{Vararg{AbstractUnitRange}}
)
  # TODO: Make `(::OpName)(domain...)` constructor process more general inputs.
  return state_or_op_convert(n, arrtype, domain, reversed_sites(n, domain))
end

function op(arrtype::Type{<:AbstractArray}, n::String, domain...; kwargs...)
  return arrtype(opexpr(n; kwargs...), domain...)
end
function op(elt::Type{<:Number}, n::String, domain...; kwargs...)
  return op(AbstractArray{elt}, n, domain...; kwargs...)
end
function op(n::String, domain...; kwargs...)
  return op(AbstractArray, n, domain...; kwargs...)
end

# Unary operations
for nametype in (:StateName, :OpName)
  applied = :($(nametype){:applied})
  @eval begin
    nsites(n::$(applied)) = nsites(n.arg)
    function (n::$(applied))(domain...)
      return n.f(n.arg(domain...))
    end
  end
  for f in (
    :(Base.real),
    :(Base.imag),
    :(Base.complex),
    # :(Base.adjoint), # Decide on this, since this becomes a matrix.
    :(Base.:+),
    :(Base.:-),
  )
    @eval begin
      $f(n::$(nametype)) = $(applied)(; f=$f, arg=n)
    end
  end
end

for nametype in (:StateName, :OpName)
  kronned = :($(nametype){:kronned})
  @eval begin
    nsites(n::$(kronned)) = sum(nsites, n.args)
    function (n::$(kronned))(domain...)
      # TODO: Generalize beyond two arguments.
      # Use `cumsum(nsites.(n.args))`.
      stops = cumsum(nsites.(n.args))
      starts = [1, stops[1:(end - 1)] .+ 1...]
      domains = map((start, stop) -> domain[start:stop], starts, stops)
      return kron(map((arg, domain) -> arg(domain...), n.args, domains)...)
    end
    Base.kron(n1::$(nametype), n2::$(nametype), n_rest::$(nametype)...) =
      $(kronned)(; args=(n1, n2, n_rest...))
    ⊗(n1::$(nametype), n2::$(nametype)) = kron(n1, n2)
    ⊗(n1::$(kronned), n2::$(kronned)) = kron(n1.args..., n2.args...)
    ⊗(n1::$(nametype), n2::$(kronned)) = kron(n1, n2.args...)
    ⊗(n1::$(kronned), n2::$(nametype)) = kron(n1.args..., n2)
  end
end

for nametype in (:StateName, :OpName)
  summed = :($(nametype){:summed})
  @eval begin
    function nsites(n::$(summed))
      # TODO: Use `allequal(nsites, n.args)` once we drop Julia 1.10 support.
      @assert allequal(nsites.(n.args))
      return nsites(first(n.args))
    end
    function (n::$(summed))(domain...)
      return mapreduce(a -> a(domain...), +, n.args)
    end
    Base.:+(n1::$(nametype), n2::$(nametype), n_rest::$(nametype)...) =
      $(summed)(; args=(n1, n2, n_rest...))
    Base.:+(n1::$(summed), n2::$(summed)) = +(n1.args..., n2.args...)
    Base.:+(n1::$(summed), n2::$(nametype)) = +(n1.args..., n2)
    Base.:+(n1::$(nametype), n2::$(summed)) = +(n1, n2.args...)
    Base.:-(n1::$(nametype), n2::$(nametype)) = n1 + (-n2)
  end
end

for nametype in (:StateName, :OpName)
  scaled = :($(nametype){:scaled})
  @eval begin
    nsites(n::$(scaled)) = nsites(n.arg)
    function (n::$(scaled))(domain...)
      return n.arg(domain...) * n.c
    end
    function Base.:*(c::Number, n::$(nametype))
      return $(scaled)(; arg=n, c)
    end
    function Base.:*(n::$(nametype), c::Number)
      return $(scaled)(; arg=n, c)
    end
    function Base.:/(n::$(nametype), c::Number)
      return $(scaled)(; arg=n, c=inv(c))
    end

    function Base.:*(c::Number, n::$(scaled))
      return $(scaled)(; arg=n.arg, c=(c * n.c))
    end
    function Base.:*(n::$(scaled), c::Number)
      return $(scaled)(; arg=n.arg, c=(n.c * c))
    end
    function Base.:/(n::$(scaled), c::Number)
      return $(scaled)(; arg=n.arg, c=(n.c / c))
    end
  end
end

# Unary operations unique to operators.
for f in (:(Base.sqrt), :(Base.exp), :(Base.cis), :(Base.cos), :(Base.sin), :(Base.adjoint))
  @eval begin
    $f(n::OpName) = OpName"applied"(; f=$f, arg=n)
  end
end

nsites(n::OpName"exponentiated") = nsites(n.arg)
function (n::OpName"exponentiated")(domain...)
  return n.arg(domain...)^n.exponent
end
Base.:^(n::OpName, exponent) = OpName"exponentiated"(; arg=n, exponent)

function nsites(n::OpName"producted")
  # TODO: Use `allequal(nsites, n.args)` once we drop Julia 1.10 support.
  @assert allequal(nsites.(n.args))
  return nsites(first(n.args))
end
function (n::OpName"producted")(domain...)
  return mapreduce(a -> a(domain...), *, n.args)
end
function Base.:*(n1::OpName, n2::OpName, n_rest::OpName...)
  return OpName"producted"(; args=(n1, n2, n_rest...))
end
Base.:*(n1::StateName"producted", n2::StateName"producted") = *(n1.args..., n2.args...)
Base.:*(n1::StateName, n2::StateName"producted") = *(n1, n2.args...)
Base.:*(n1::StateName"producted", n2::StateName) = *(n1.args..., n2)

controlled(n::OpName; ncontrol=1) = OpName"Controlled"(; ncontrol, arg=n)

using LinearAlgebra: Diagonal
function (::OpName"Id")(domain)
  return Diagonal(trues(to_dim(domain)))
end
function (n::OpName"Id")(domain1, domain_rest...)
  domain = (domain1, domain_rest)
  return kron(ntuple(Returns(n), length(domain))...)(domain...)
end
@op_alias "I" "Id"
@op_alias "σ0" "Id"
@op_alias "σ⁰" "Id"
@op_alias "σ₀" "Id"
# TODO: Is this a good definition?
@op_alias "F" "Id"

function (n::OpName"StandardBasis")(domain)
  d = to_dim(domain)
  a = falses(d, d)
  a[n.index...] = one(Bool)
  return a
end

function alias(n::OpName"Proj")
  return OpName"StandardBasis"(; index=(n.index, n.index))
end
@op_alias "proj" "Proj"

function (n::OpName"a†")(domain)
  d = to_dim(domain)
  a = zeros(d, d)
  for k in 1:(d - 1)
    a[k + 1, k] = √k
  end
  return a
end
@op_alias "Adag" "a†"
@op_alias "adag" "a†"
alias(::OpName"a") = OpName"a†"()'
@op_alias "A" "a"

alias(::OpName"n") = OpName"a†"() * OpName"a"()
@op_alias "N" "n"

# `cis(x) = exp(im * x)`
alias(n::OpName"Phase") = cis(n.θ * OpName"n"())
@op_alias "PHASE" "Phase"
@op_alias "P" "Phase"
@op_alias "π/8" "Phase" θ = π / 4
@op_alias "T" "π/8"
@op_alias "S" "Phase" θ = π / 2

alias(::OpName"aa") = OpName("a") ⊗ OpName("a")
alias(::OpName"a†a") = OpName("a†") ⊗ OpName("a")
alias(::OpName"aa†") = OpName("a") ⊗ OpName("a†")
alias(::OpName"a†a†") = OpName("a†") ⊗ OpName("a†")

δ(x, y) = (x == y) ? 1 : 0

# See:
# https://en.wikipedia.org/wiki/Spin_(physics)#Higher_spins
# https://en.wikipedia.org/wiki/Pauli_matrices
# https://en.wikipedia.org/wiki/Generalizations_of_Pauli_matrices
# https://en.wikipedia.org/wiki/Generalized_Clifford_algebra
# https://github.com/QuantumKitHub/MPSKitModels.jl/blob/v0.4.0/src/operators/spinoperators.jl
function (n::OpName"σ⁺")(domain)
  d = to_dim(domain)
  s = (d - 1) / 2
  return [2 * δ(i + 1, j) * √((s + 1) * (i + j - 1) - i * j) for i in 1:d, j in 1:d]
end
alias(::OpName"S+") = OpName("σ⁺") / 2
@op_alias "S⁺" "S+"
@op_alias "Splus" "S+"
@op_alias "Sp" "S+"

alias(::OpName"σ⁻") = OpName"σ⁺"()'
alias(::OpName"S-") = OpName("σ⁻") / 2
@op_alias "S⁻" "S-"
@op_alias "Sminus" "S-"
@op_alias "Sm" "S-"

alias(::OpName"X") = (OpName"σ⁺"() + OpName"σ⁻"()) / 2
@op_alias "σx" "X"
@op_alias "σˣ" "X"
@op_alias "σₓ" "X"
@op_alias "σ1" "X"
@op_alias "σ¹" "X"
@op_alias "σ₁" "X"
@op_alias "σy" "Y"
alias(::OpName"iX") = im * OpName"X"()
alias(::OpName"√X") = √OpName"X"()
@op_alias "√NOT" "√X"
alias(n::OpName"Sx") = OpName"X"() / 2
@op_alias "Sˣ" "Sx"
@op_alias "Sₓ" "Sx"
alias(::OpName"Sx2") = OpName"Sx"()^2

# Generic rotation.
# exp(-im * θ / 2 * O)
alias(n::OpName"R") = cis(-(n.θ / 2) * n.arg)

# Rotation around X-axis
# exp(-im * θ / 2 * X)
alias(n::OpName"Rx") = OpName"R"(; params(n)..., arg=OpName"X"())

alias(::OpName"Y") = -im * (OpName"σ⁺"() - OpName"σ⁻"()) / 2
# TODO: No subsript `\_y` available
# in unicode.
@op_alias "σʸ" "Y"
@op_alias "σ2" "Y"
@op_alias "σ²" "Y"
@op_alias "σ₂" "Y"
alias(::OpName"iY") = (OpName"σ⁺"() - OpName"σ⁻"()) / 2
@op_alias "iσy" "iY"
# TODO: No subsript `\_y` available
# in unicode.
@op_alias "iσʸ" "iY"
@op_alias "iσ2" "iY"
@op_alias "iσ²" "iY"
@op_alias "iσ₂" "iY"
alias(n::OpName"Sy") = OpName"Y"() / 2
@op_alias "Sʸ" "Sy"
alias(n::OpName"iSy") = OpName"iY"() / 2
@op_alias "iSʸ" "iSy"
alias(::OpName"Sy2") = -OpName"iSy"()^2

# Rotation around Y-axis
# exp(-im * θ / 2 * Y) = exp(-θ / 2 * iY)
alias(n::OpName"Ry") = OpName"R"(; params(n)..., arg=OpName"Y"())

# Ising (XX) coupling gate
# exp(-im * θ/2 * X ⊗ X)
alias(n::OpName"Rxx") = OpName"R"(; params(n)..., arg=OpName"X"() ⊗ OpName"X"())
@op_alias "RXX" "Rxx"

# Ising (YY) coupling gate
# exp(-im * θ/2 * Y ⊗ Y)
alias(n::OpName"Ryy") = OpName"R"(; params(n)..., arg=OpName"Y"() ⊗ OpName"Y"())
@op_alias "RYY" "Ryy"

# Ising (ZZ) coupling gate
# exp(-im * θ/2 * Z ⊗ Z)
alias(n::OpName"Rzz") = OpName"R"(; params(n)..., arg=OpName"Z"() ⊗ OpName"Z"())
@op_alias "RZZ" "Rzz"

## TODO: Check this definition and see if it is worth defining this.
## # Ising (XY) coupling gate
## # exp(-im * θ/2 * X ⊗ Y)
## alias(n::OpName"Rxy") = exp(-im * (n.θ / 2) * OpName"X"() ⊗ OpName"Y"())
## @op_alias "RXY" "Rxy"

function (n::OpName"σᶻ")(domain)
  d = to_dim(domain)
  s = (d - 1) / 2
  return Diagonal([2 * (s + 1 - i) for i in 1:d])
end
# TODO: No subsript `\_z` available
# in unicode.
@op_alias "Z" "σᶻ"
@op_alias "σ3" "Z"
@op_alias "σ³" "Z"
@op_alias "σ₃" "Z"
@op_alias "σz" "Z"
alias(::OpName"iZ") = im * OpName"Z"()
alias(n::OpName"Sz") = OpName"Z"() / 2
@op_alias "Sᶻ" "Sz"
# TODO: Make sure it ends up real, using `S⁺` and `S⁻`,
# define `Sx²`, `Sy²`, and `Sz²`, etc.
# Should be equal to:
# ```julia
# α * I = s * (s + 1) * I
#   = (d - 1) * (d + 1) / 4 * I
# ```
# where `s = (d - 1) / 2`. See https://en.wikipedia.org/wiki/Spin_(physics)#Higher_spins.
alias(n::OpName"S2") = OpName"Sx2"() + OpName"Sy2"() + OpName"Sz2"()
@op_alias "S²" "S2"
alias(::OpName"Sz2") = OpName"Sz"()^2

# Rotation around Z-axis
# exp(-im * θ / 2 * Z)
alias(n::OpName"Rz") = OpName"R"(; params(n)..., arg=OpName"Z"())

using LinearAlgebra: eigen
function (n::OpName"H")(domain)
  Λ, H = eigen(OpName("X")(domain))
  p = sortperm(Λ; rev=true)
  return H[:, p]
end

using LinearAlgebra: Diagonal
nsites(::OpName"SWAP") = 2
function (::OpName"SWAP")(domain1, domain2)
  domain = to_dim.((domain1, domain2))
  I_matrix = Diagonal(trues(prod(domain)))
  I_array = reshape(I_matrix, (domain..., domain...))
  SWAP_array = permutedims(I_array, (2, 1, 3, 4))
  SWAP_matrix = reshape(SWAP_array, (prod(domain), prod(domain)))
  return SWAP_matrix
end
@op_alias "Swap" "SWAP"
alias(::OpName"√SWAP") = √(OpName"SWAP"())
@op_alias "√Swap" "√SWAP"

using LinearAlgebra: diagind
nsites(::OpName"iSWAP") = 2
function (::OpName"iSWAP")(domain1, domain2)
  domain = (domain1, domain2)
  swap = OpName"SWAP"()(domain...)
  iswap = im * swap
  iswap[diagind(iswap)] .*= -im
  return iswap
end
@op_alias "iSwap" "iSWAP"
alias(::OpName"√iSWAP") = √(OpName"iSWAP"())
@op_alias "√iSwap" "√iSWAP"

# TODO: Generalize to more controlled operators, right now
# there is only one controlled operator that is enabled when
# all of the last values of each sites/Qudit is set. See:
# https://docs.quantum.ibm.com/api/qiskit/qiskit.circuit.library.UCGate
# https://arxiv.org/abs/2410.05122
nsites(n::OpName"Controlled") = get(params(n), :ncontrol, 1) + nsites(n.arg)
function (n::OpName"Controlled")(domain...)
  # Number of target sites.
  nt = nsites(n.arg)
  # Number of control sites.
  nc = get(params(n), :ncontrol, length(domain) - nt)
  @assert length(domain) == nc + nt
  d_control = prod(to_dim.(domain)) - prod(to_dim.(domain[(nc + 1):end]))
  return cat(I(d_control), n.arg(domain[(nc + 1):end]...); dims=(1, 2))
end
@op_alias "CNOT" "Controlled" arg = OpName"X"()
@op_alias "CX" "Controlled" arg = OpName"X"()
@op_alias "CY" "Controlled" arg = OpName"Y"()
@op_alias "CZ" "Controlled" arg = OpName"Z"()
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

@op_alias "CCNOT" "Controlled" ncontrol = 2 arg = OpName"X"()
@op_alias "Toffoli" "CCNOT"
@op_alias "CCX" "CCNOT"
@op_alias "TOFF" "CCNOT"

@op_alias "CSWAP" "Controlled" ncontrol = 2 arg = OpName"SWAP"()
@op_alias "Fredkin" "CSWAP"
@op_alias "CSwap" "CSWAP"
@op_alias "CS" "CSWAP"

@op_alias "CCCNOT" "Controlled" ncontrol = 3 arg = OpName"X"()

## # 1-qudit rotation around generic axis n̂.
## # exp(-im * α / 2 * n̂ ⋅ σ⃗)
## function (n::OpName"Rn")(domain)
##   # TODO: Is this a good parametrization?
##   n̂ = (sin(n.θ/2) * cos(n.ϕ), sin(n.θ/2) * sin(n.ϕ/2), cos(n.θ/2))
##   σ⃗ = (OpName"X"(domain), OpName"Y"(domain), OpName"Z"(domain))
##   n̂σ⃗ = mapreduce(*, +, n̂, σ⃗)
##   return cis(-(n.λ/2) * n̂σ⃗)
## end
## @op_alias "Rn̂" "Rn"

# Version of `sign` that returns one
# if `x == 0`.
function nonzero_sign(x)
  iszero(x) && return one(x)
  return sign(x)
end

function qr_positive(M::AbstractMatrix)
  Q, R = qr(M)
  Q′ = typeof(R)(Q)
  signs = nonzero_sign.(diag(R))
  Q′ = Q′ * Diagonal(signs)
  R = Diagonal(conj.(signs)) * R
  return Q′, R
end

using Random: Random
function (n::OpName"RandomUnitary")(domain...)
  elt = get(params(n), :eltype, Complex{Float64})
  rng = get(params(n), :rng, Random.default_rng())
  d = prod(to_dim.(domain))
  Q, _ = qr_positive(randn(rng, elt, (d, d)))
  return Q
end
@op_alias "randU" "RandomUnitary"

# Expand the operator in a new basis.
using LinearAlgebra: ⋅
function expand(v::AbstractArray, basis)
  gramian = [basisᵢ ⋅ basisⱼ for basisᵢ in basis, basisⱼ in basis]
  vbasis = [basisᵢ ⋅ v for basisᵢ in basis]
  return gramian \ vbasis
end
function expand(n::OpName, basis, ts...)
  return expand(AbstractArray(n, ts...), map(basisᵢ -> AbstractArray(basisᵢ, ts...), basis))
end
