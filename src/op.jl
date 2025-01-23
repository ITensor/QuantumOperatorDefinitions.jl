struct OpName{Name,Params}
  params::Params
end
params(n::OpName) = getfield(n, :params)

Base.getproperty(n::OpName, name::Symbol) = getfield(params(n), name)

OpName{N}(params) where {N} = OpName{N,typeof(params)}(params)
OpName{N}(; kwargs...) where {N} = OpName{N}((; kwargs...))

OpName(s::AbstractString; kwargs...) = OpName{Symbol(s)}(; kwargs...)
OpName(s::Symbol; kwargs...) = OpName{s}(; kwargs...)
name(::OpName{N}) where {N} = N
macro OpName_str(s)
  return OpName{Symbol(s)}
end

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

# `Int(ndims // 2)`, i.e. `ndims_domain`/`ndims_codomain`.
function nsites(n::Union{StateName,OpName})
  n′ = alias(n)
  if n′ == n
    # Default value, assume 1-site operator/state.
    return 1
  end
  return nsites(n′)
end

## TODO: Delete.
## # Default implementations of op
## op(::OpName; kwargs...) = nothing
## op(::OpName, ::SiteType; kwargs...) = nothing

function _sitetypes(ts::Set)
  return collect(SiteType, SiteType.(ts))
end

## TODO: Delete.
## op(name::AbstractString; kwargs...) = error("Must input indices when creating an `op`.")

# To ease calling of other op overloads,
# allow passing a string as the op name
## TODO: Bring this back?
## op(opname::AbstractString, t::SiteType; kwargs...) = op(OpName(opname), t; kwargs...)

# TODO: Bring this back?
# op(f::Function, args...; kwargs...) = f(op(args...; kwargs...))

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
@op_alias "S+" "S⁺"
@op_alias "Splus" "S+"
@op_alias "Sp" "S+"

alias(::OpName"σ⁻") = OpName"σ⁺"()'
alias(::OpName"S⁻") = OpName("σ⁻") / 2
@op_alias "S-" "S⁻"
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
@op_alias "iX" "im" op = OpName"X"()
@op_alias "√X" "√" op = OpName"X"()
@op_alias "√NOT" "√" op = OpName"X"()
alias(n::OpName"Sx") = OpName("X") / 2
@op_alias "Sˣ" "Sx"
@op_alias "Sₓ" "Sx"

alias(::OpName"Y") = -im * (OpName"σ⁺"() - OpName"σ⁻"()) / 2
# TODO: No subsript `\_y` available
# in unicode.
@op_alias "σʸ" "Y"
@op_alias "σ2" "Y"
@op_alias "σ²" "Y"
@op_alias "σ₂" "Y"
function alias(::OpName"iY")
  return real(OpName"Y"()im)
end
@op_alias "iσy" "iY"
# TODO: No subsript `\_y` available
# in unicode.
@op_alias "iσʸ" "iY"
@op_alias "iσ2" "iY"
@op_alias "iσ²" "iY"
@op_alias "iσ₂" "iY"
alias(n::OpName"Sy") = OpName("Y") / 2
@op_alias "Sʸ" "Sy"
alias(n::OpName"iSy") = OpName("iY") / 2
@op_alias "iSʸ" "iSy"

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
@op_alias "iZ" "im" op = OpName"Z"()
alias(n::OpName"Sz") = OpName("Z") / 2
@op_alias "Sᶻ" "Sz"
# TODO: Make sure it ends up real, using `S⁺` and `S⁻`,
# define `Sx²`, `Sy²`, and `Sz²`, etc.
# Should be equal to:
# ```julia
# α * I = s * (s + 1) * I
#   = (d - 1) * (d + 1) / 4 * I
# ```
# where `s = (d - 1) / 2`. See https://en.wikipedia.org/wiki/Spin_(physics)#Higher_spins.
alias(n::OpName"S2") = (OpName("Sˣ")^2 + OpName("Sʸ")^2 + OpName("Sᶻ")^2)
@op_alias "S²" "S2"

using LinearAlgebra: eigen
function Base.AbstractArray(n::OpName"H", domain_size::Tuple{Int})
  Λ, H = eigen(AbstractArray(OpName("X"), domain_size))
  p = sortperm(Λ; rev=true)
  return H[:, p]
end

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

# Unary operations
nsites(n::OpName"f") = nsites(n.op)
function Base.AbstractArray(n::OpName"f", domain_size::Tuple{Vararg{Int}})
  return n.f(AbstractArray(n.op, domain_size))
end

for f in (
  :(Base.sqrt),
  :(Base.real),
  :(Base.imag),
  :(Base.complex),
  :(Base.exp),
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

alias(n::OpName"im") = OpName"scaled"(; op=n.op, c=im)

controlled(n::OpName; ncontrol=1) = OpName"Control"(; ncontrol, op=n)

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
