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
function (arrtype::Type{<:AbstractArray})(n::OpName)
  return arrtype(n, ntuple(Returns(default_sitetype()), nsites(n)))
end

using LinearAlgebra: Diagonal
Base.AbstractArray(::OpName"Id", ts::Tuple{SiteType}) = Diagonal(trues(length.(ts)))

# `Int(ndims // 2)`, i.e. `ndims_domain`/`ndims_codomain`.
function nsites(n::Union{StateName,OpName})
  n′ = alias(n)
  if n′ == n
    # Default value, assume 1-site operator/state.
    return 1
  end
  return nsites(n′)
end

nsites(n::OpName"Control") = get(params(n), :ncontrol, 1) + nsites(n.op)
