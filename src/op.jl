using Random: randstring

struct OpName{Name,Params}
  function OpName{Name,Params}(params::NamedTuple) where {Name,Params}
    return new{Name,(; Params..., params...)}()
  end
end
name(::OpName{Name}) where {Name} = Name
params(::OpName{<:Any,Params}) where {Params} = Params

Base.getproperty(n::OpName, name::Symbol) = getfield(params(n), name)

OpName{Name,Params}(; kwargs...) where {Name,Params} = OpName{Name,Params}((; kwargs...))

OpName{N}(params::NamedTuple) where {N} = OpName{N,params}()
OpName{N}(; kwargs...) where {N} = OpName{N}((; kwargs...))

const DAGGER_STRING = randstring()
const UPARROW_STRING = randstring()
const DOWNARROW_STRING = randstring()
const OPEXPR_REPLACEMENTS = (
  "†" => DAGGER_STRING, "↑" => UPARROW_STRING, "↓" => DOWNARROW_STRING
)

# This compiles operator expressions, such as:
# ```julia
# opexpr("X + Y") == OpName("X") + OpName("Y")
# opexpr("Ry{θ=π/2}") == OpName("Ry"; θ=π/2)
# ```
function opexpr(n::String; kwargs...)
  n = replace(n, OPEXPR_REPLACEMENTS...)
  return opexpr(Meta.parse(n); kwargs...)
end
opexpr(n::Number) = n
function opexpr(n::Symbol; kwargs...)
  n === :im && return im
  n === :π && return π
  n = Symbol(replace(String(n), reverse.(OPEXPR_REPLACEMENTS)...))
  return OpName{n}(; kwargs...)
end
function opexpr(ex::Expr)
  if Meta.isexpr(ex, :call)
    return eval(ex.args[1])(opexpr.(ex.args[2:end])...)
  end
  if Meta.isexpr(ex, :curly)
    # Syntax for parametrized gates, i.e.
    # `opexpr("Ry{θ=π/2}")`.
    params = ex.args[2:end]
    kwargs = Dict(
      map(params) do param
        @assert Meta.isexpr(param, :(=))
        return param.args[1] => eval(param.args[2])
      end,
    )
    return OpName{ex.args[1]}(; kwargs...)
  end
  return error("Can't parse expression $ex.")
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

for f in (
  :(Base.sqrt),
  :(Base.real),
  :(Base.imag),
  :(Base.complex),
  :(Base.exp),
  :(Base.cis),
  :(Base.cos),
  :(Base.sin),
  :(Base.adjoint),
  :(Base.:+),
  :(Base.:-),
)
  @eval begin
    $f(n::OpName) = OpName"f"(; f=$f, op=n)
  end
end

# Unary operations
nsites(n::OpName"f") = nsites(n.op)
function Base.AbstractArray(n::OpName"f", domain_size::Tuple{Vararg{Int}})
  return n.f(AbstractArray(n.op, domain_size))
end

nsites(n::OpName"^") = nsites(n.op)
function Base.AbstractArray(n::OpName"^", domain_size::Tuple{Vararg{Int}})
  return AbstractArray(n.op, domain_size)^n.exponent
end
Base.:^(n::OpName, exponent) = OpName"^"(; op=n, exponent)

nsites(n::OpName"kron") = nsites(n.op1) + nsites(n.op2)
function Base.AbstractArray(n::OpName"kron", domain_size::Tuple{Vararg{Int}})
  domain_size1 = domain_size[1:nsites(n.op1)]
  domain_size2 = domain_size[(nsites(n.op1) + 1):end]
  @assert length(domain_size2) == nsites(n.op2)
  return kron(AbstractArray(n.op1, domain_size1), AbstractArray(n.op2, domain_size2))
end
Base.kron(n1::OpName, n2::OpName) = OpName"kron"(; op1=n1, op2=n2)
⊗(n1::OpName, n2::OpName) = kron(n1, n2)

function nsites(n::OpName"+")
  @assert nsites(n.op1) == nsites(n.op2)
  return nsites(n.op1)
end
function Base.AbstractArray(n::OpName"+", domain_size::Tuple{Vararg{Int}})
  return AbstractArray(n.op1, domain_size) + AbstractArray(n.op2, domain_size)
end
Base.:+(n1::OpName, n2::OpName) = OpName"+"(; op1=n1, op2=n2)
Base.:-(n1::OpName, n2::OpName) = n1 + (-n2)

function nsites(n::OpName"*")
  @assert nsites(n.op1) == nsites(n.op2)
  return nsites(n.op1)
end
function Base.AbstractArray(n::OpName"*", domain_size::Tuple{Vararg{Int}})
  return AbstractArray(n.op1, domain_size) * AbstractArray(n.op2, domain_size)
end
Base.:*(n1::OpName, n2::OpName) = OpName"*"(; op1=n1, op2=n2)

nsites(n::OpName"scaled") = nsites(n.op)
function Base.AbstractArray(n::OpName"scaled", domain_size::Tuple{Vararg{Int}})
  return AbstractArray(n.op, domain_size) * n.c
end
function Base.:*(c::Number, n::OpName)
  return OpName"scaled"(; op=n, c)
end
function Base.:*(n::OpName, c::Number)
  return OpName"scaled"(; op=n, c)
end
function Base.:/(n::OpName, c::Number)
  return OpName"scaled"(; op=n, c=inv(c))
end

function Base.:*(c::Number, n::OpName"scaled")
  return OpName"scaled"(; op=n.op, c=(c * n.c))
end
function Base.:*(n::OpName"scaled", c::Number)
  return OpName"scaled"(; op=n.op, c=(n.c * c))
end
function Base.:/(n::OpName"scaled", c::Number)
  return OpName"scaled"(; op=n.op, c=(n.c / c))
end

controlled(n::OpName; ncontrol=1) = OpName"Controlled"(; ncontrol, op=n)

function op_alias_expr(name1, name2, pars...)
  return :(function alias(n::OpName{Symbol($name1)})
    return OpName{Symbol($name2)}(; params(n)..., $(esc.(pars)...))
  end)
end
macro op_alias(name1, name2, pars...)
  return op_alias_expr(name1, name2, pars...)
end

alias(n::OpName) = n
function op_convert(
  arrtype::Type{<:AbstractArray{<:Any,N}},
  domain_size::Tuple{Vararg{Integer}},
  a::AbstractArray{<:Any,N},
) where {N}
  # TODO: Check the dimensions.
  return convert(arrtype, a)
end
function op_convert(
  arrtype::Type{<:AbstractArray}, domain_size::Tuple{Vararg{Integer}}, a::AbstractArray
)
  # TODO: Check the dimensions.
  return convert(arrtype, a)
end
function op_convert(
  arrtype::Type{<:AbstractArray{<:Any,N}},
  domain_size::Tuple{Vararg{Integer}},
  a::AbstractArray,
) where {N}
  size = (domain_size..., domain_size...)
  @assert length(size) == N
  return convert(arrtype, reshape(a, size))
end
function (arrtype::Type{<:AbstractArray})(n::OpName, ts::Tuple{Vararg{SiteType}})
  return op_convert(arrtype, length.(ts), AbstractArray(n, ts))
end
function (arrtype::Type{<:AbstractArray})(n::OpName, domain_size::Tuple{Vararg{Integer}})
  return op_convert(arrtype, domain_size, AbstractArray(n, Int.(domain_size)))
end
function (arrtype::Type{<:AbstractArray})(n::OpName, domain_size::Integer...)
  return arrtype(n, domain_size)
end
(arrtype::Type{<:AbstractArray})(n::OpName, ts::SiteType...) = arrtype(n, ts)
Base.AbstractArray(n::OpName, ts::SiteType...) = AbstractArray(n, ts)
function Base.AbstractArray(n::OpName, ts::Tuple{Vararg{SiteType}})
  n′ = alias(n)
  ts′ = alias.(ts)
  if n′ == n && ts′ == ts
    return AbstractArray(n′, length.(ts′))
  end
  return AbstractArray(n′, ts′)
end
function Base.AbstractArray(n::OpName, domain_size::Tuple{Vararg{Int}})
  n′ = alias(n)
  if n′ == n
    error("Not implemented.")
  end
  return AbstractArray(n′, domain_size)
end

# TODO: Decide on this.
function Base.AbstractArray(n::OpName)
  return AbstractArray(n, ntuple(Returns(default_sitetype()), nsites(n)))
end
function (arrtype::Type{<:AbstractArray})(n::OpName)
  return arrtype(n, ntuple(Returns(default_sitetype()), nsites(n)))
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

# `Int(ndims // 2)`, i.e. `ndims_domain`/`ndims_codomain`.
function nsites(n::Union{StateName,OpName})
  n′ = alias(n)
  if n′ == n
    # Default value, assume 1-site operator/state.
    return 1
  end
  return nsites(n′)
end

using LinearAlgebra: Diagonal
function Base.AbstractArray(::OpName"Id", domain_size::Tuple{Int})
  return Diagonal(trues(only(domain_size)))
end
function Base.AbstractArray(n::OpName"Id", domain_size::Tuple{Int,Vararg{Int}})
  return Base.AbstractArray(kron(ntuple(Returns(n), length(domain_size))...), domain_size)
end
@op_alias "I" "Id"
@op_alias "σ0" "Id"
@op_alias "σ⁰" "Id"
@op_alias "σ₀" "Id"
# TODO: Is this a good definition?
@op_alias "F" "Id"

# TODO: Define as `::Tuple{Int}`.
function Base.AbstractArray(n::OpName"a†", domain_size::Tuple{Int})
  d = only(domain_size)
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
function Base.AbstractArray(n::OpName"σ⁺", domain_size::Tuple{Int})
  d = only(domain_size)
  s = (d - 1) / 2
  return [2 * δ(i + 1, j) * √((s + 1) * (i + j - 1) - i * j) for i in 1:d, j in 1:d]
end
alias(::OpName"S⁺") = OpName("σ⁺") / 2
@op_alias "Splus" "S⁺"
@op_alias "Sp" "S⁺"

alias(::OpName"σ⁻") = OpName"σ⁺"()'
alias(::OpName"S⁻") = OpName("σ⁻") / 2
@op_alias "Sminus" "S⁻"
@op_alias "Sm" "S⁻"

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

# Rotation around X-axis
# exp(-im * n.θ / 2 * X)
alias(n::OpName"Rx") = cis(-(n.θ / 2) * OpName"X"())

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
# exp(-im * n.θ / 2 * Y)
alias(n::OpName"Ry") = exp(-(n.θ / 2) * OpName"iY"())

# Ising (XX) coupling gate
# exp(-im * θ/2 * X ⊗ X)
alias(n::OpName"Rxx") = exp(-im * (n.θ / 2) * OpName"X"() ⊗ OpName"X"())
@op_alias "RXX" "Rxx"

# Ising (YY) coupling gate
# exp(-im * θ/2 * Y ⊗ Y)
alias(n::OpName"Ryy") = exp(-im * (n.θ / 2) * OpName"Y"() ⊗ OpName"Y"())
@op_alias "RYY" "Ryy"

# Ising (ZZ) coupling gate
# exp(-im * θ/2 * Z ⊗ Z)
alias(n::OpName"Rzz") = exp(-im * (n.θ / 2) * OpName"Z"() ⊗ OpName"Z"())
@op_alias "RZZ" "Rzz"

## TODO: Check this definition and see if it is worth defining this.
## # Ising (XY) coupling gate
## # exp(-im * θ/2 * X ⊗ Y)
## alias(n::OpName"Rxy") = exp(-im * (n.θ / 2) * OpName"X"() ⊗ OpName"Y"())
## @op_alias "RXY" "Rxy"

function Base.AbstractArray(n::OpName"σᶻ", domain_size::Tuple{Int})
  d = only(domain_size)
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
# exp(-im * n.θ / 2 * Z)
alias(n::OpName"Rz") = exp(-im * (n.θ / 2) * OpName"Z"())

using LinearAlgebra: eigen
function Base.AbstractArray(n::OpName"H", domain_size::Tuple{Int})
  Λ, H = eigen(AbstractArray(OpName("X"), domain_size))
  p = sortperm(Λ; rev=true)
  return H[:, p]
end

using LinearAlgebra: Diagonal
nsites(::OpName"SWAP") = 2
function Base.AbstractArray(::OpName"SWAP", domain_size::Tuple{Int,Int})
  I_matrix = Diagonal(trues(prod(domain_size)))
  I_array = reshape(I_matrix, (domain_size..., domain_size...))
  SWAP_array = permutedims(I_array, (2, 1, 3, 4))
  SWAP_matrix = reshape(SWAP_array, (prod(domain_size), prod(domain_size)))
  return SWAP_matrix
end
@op_alias "Swap" "SWAP"
alias(::OpName"√SWAP") = √(OpName"SWAP"())
@op_alias "√Swap" "√SWAP"

using LinearAlgebra: diagind
nsites(::OpName"iSWAP") = 2
function Base.AbstractArray(::OpName"iSWAP", domain_size::Tuple{Int,Int})
  swap = AbstractArray(OpName"SWAP"(), domain_size)
  iswap = im * swap
  iswap[diagind(iswap)] .*= -im
  return iswap
end
@op_alias "iSwap" "iSWAP"
alias(::OpName"√iSWAP") = √(OpName"iSWAP"())
@op_alias "√iSwap" "√iSWAP"

## TODO: Bring back these definitions.
## function default_random_matrix(eltype::Type, s::Index...)
##   n = prod(dim.(s))
##   return randn(eltype, n, n)
## end
##
## # Haar-random unitary
## #
## # Reference:
## # Section 4.6
## # http://math.mit.edu/~edelman/publications/random_matrix_theory.pdf
## function op!(
##   o::ITensor,
##   ::OpName"RandomUnitary",
##   ::SiteType"Generic",
##   s1::Index,
##   sn::Index...;
##   eltype=ComplexF64,
##   random_matrix=default_random_matrix(eltype, s1, sn...),
## )
##   s = (s1, sn...)
##   Q, _ = NDTensors.qr_positive(random_matrix)
##   t = itensor(Q, prime.(s)..., dag.(s)...)
##   return settensor!(o, tensor(t))
## end
##
## function op!(o::ITensor, ::OpName"randU", st::SiteType"Generic", s::Index...; kwargs...)
##   return op!(o, OpName("RandomUnitary"), st, s...; kwargs...)
## end

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
