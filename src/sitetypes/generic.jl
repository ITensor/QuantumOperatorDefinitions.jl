#########################################################################################
# SiteType
#########################################################################################
alias(t::SiteType) = t
Base.AbstractUnitRange(t::SiteType) = Base.OneTo(length(t))
Base.size(t::SiteType) = (length(t),)
Base.size(t::SiteType, dim::Integer) = size(t)[dim]
Base.axes(t::SiteType) = (AbstractUnitRange(t),)
Base.axes(t::SiteType, dim::Integer) = axes(t)[dim]

# TODO: Decide on this.
default_sitetype() = SiteType"Qubit"()

#########################################################################################
# StateName
#########################################################################################
alias(n::StateName) = n
function (arrtype::Type{<:AbstractArray})(n::StateName, ts::Tuple{Vararg{SiteType}})
  return convert(arrtype, AbstractArray(n, ts))
end
(arrtype::Type{<:AbstractArray})(n::StateName, ts::SiteType...) = arrtype(n, ts)
function Base.AbstractArray(n::StateName, ts::Tuple{Vararg{SiteType}})
  n′ = alias(n)
  ts′ = alias.(ts)
  if n′ == n && ts′ == ts
    error("No definition found.")
  end
  return AbstractArray(n′, ts′)
end

# TODO: Decide on this.
function Base.AbstractArray(n::StateName)
  return AbstractArray(n, ntuple(Returns(default_sitetype()), nsites(n)))
end
function (arrtype::Type{<:AbstractArray})(n::StateName)
  return arrtype(n, ntuple(Returns(default_sitetype()), nsites(n)))
end

#########################################################################################
# OpName
#########################################################################################
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
(arrtype::Type{<:AbstractArray})(n::OpName, ts::SiteType...) = arrtype(n, ts)
Base.AbstractArray(n::OpName, ts::SiteType...) = AbstractArray(n, ts)
function Base.AbstractArray(n::OpName, ts::Tuple{Vararg{SiteType}})
  n′ = alias(n)
  ts′ = alias.(ts)
  if n′ == n && ts′ == ts
    error("No definition found.")
  end
  return AbstractArray(n′, ts′)
end

# TODO: Decide on this.
function Base.AbstractArray(n::OpName)
  return AbstractArray(n, ntuple(Returns(default_sitetype()), nsites(n)))
end
function (arrtype::Type{<:AbstractArray})(n::OpName)
  return arrtype(n, ntuple(Returns(default_sitetype()), nsites(n)))
end

using LinearAlgebra: Diagonal
Base.AbstractArray(::OpName"Id", ts::Tuple{SiteType}) = Diagonal(trues(length.(ts)))
function Base.AbstractArray(n::OpName"Id", ts::Tuple{SiteType,Vararg{SiteType}})
  return Base.AbstractArray(kron(ntuple(Returns(n), length(ts))...), ts)
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

# Unary operations
nsites(n::OpName"f") = nsites(n.op)
function Base.AbstractArray(n::OpName"f", ts::Tuple{Vararg{SiteType}})
  return n.f(AbstractArray(n.op, ts))
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
function Base.AbstractArray(n::OpName"^", ts::Tuple{Vararg{SiteType}})
  return AbstractArray(n.op, ts)^n.exponent
end
Base.:^(n::OpName, exponent) = OpName"^"(; op=n, exponent)

nsites(n::OpName"kron") = nsites(n.op1) + nsites(n.op2)
function Base.AbstractArray(n::OpName"kron", ts::Tuple{Vararg{SiteType}})
  ts1 = ts[1:nsites(n.op1)]
  ts2 = ts[(nsites(n.op1) + 1):end]
  @assert length(ts2) == nsites(n.op2)
  return kron(AbstractArray(n.op1, ts1), AbstractArray(n.op2, ts2))
end
Base.kron(n1::OpName, n2::OpName) = OpName"kron"(; op1=n1, op2=n2)
⊗(n1::OpName, n2::OpName) = kron(n1, n2)

function nsites(n::OpName"+")
  @assert nsites(n.op1) == nsites(n.op2)
  return nsites(n.op1)
end
function Base.AbstractArray(n::OpName"+", ts::Tuple{Vararg{SiteType}})
  return AbstractArray(n.op1, ts) + AbstractArray(n.op2, ts)
end
Base.:+(n1::OpName, n2::OpName) = OpName"+"(; op1=n1, op2=n2)
Base.:-(n1::OpName, n2::OpName) = n1 + (-n2)

function nsites(n::OpName"*")
  @assert nsites(n.op1) == nsites(n.op2)
  return nsites(n.op1)
end
function Base.AbstractArray(n::OpName"*", ts::Tuple{Vararg{SiteType}})
  return AbstractArray(n.op1, ts) * AbstractArray(n.op2, ts)
end
Base.:*(n1::OpName, n2::OpName) = OpName"*"(; op1=n1, op2=n2)

nsites(n::OpName"scaled") = nsites(n.op)
function Base.AbstractArray(n::OpName"scaled", ts::Tuple{Vararg{SiteType}})
  return AbstractArray(n.op, ts) * n.c
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

nsites(n::OpName"Control") = get(params(n), :ncontrol, 1) + nsites(n.op)
nsites(n::OpName"OpSWAP") = 1 + nsites(n.op)

nsites(::OpName"Rxx") = 2
nsites(::OpName"Ryy") = 2
