struct StateName{Name,Params}
  params::Params
end
params(n::StateName) = getfield(n, :params)

Base.getproperty(n::StateName, name::Symbol) = getfield(params(n), name)

StateName{N}(params) where {N} = StateName{N,typeof(params)}(params)
StateName{N}(; kwargs...) where {N} = StateName{N}((; kwargs...))

StateName(s::AbstractString; kwargs...) = StateName{Symbol(s)}(; kwargs...)
StateName(s::Symbol; kwargs...) = StateName{s}(; kwargs...)
name(::StateName{N}) where {N} = N
macro StateName_str(s)
  return StateName{Symbol(s)}
end

function state_alias_expr(name1, name2, pars...)
  return :(function alias(n::StateName{Symbol($name1)})
    return StateName{Symbol($name2)}(; params(n)..., $(esc.(pars)...))
  end)
end
macro state_alias(name1, name2, params...)
  return state_alias_expr(name1, name2)
end

# TODO: Decide on this.
default_sitetype() = SiteType"Qubit"()

alias(n::StateName) = n
function (arrtype::Type{<:AbstractArray})(n::StateName, ts::Tuple{Vararg{SiteType}})
  # TODO: Define `state_convert` to handle reshaping multisite states
  # to higher order arrays.
  return convert(arrtype, AbstractArray(n, ts))
end
function (arrtype::Type{<:AbstractArray})(n::StateName, domain_size::Tuple{Vararg{Integer}})
  # TODO: Define `state_convert` to handle reshaping multisite states
  # to higher order arrays.
  return convert(arrtype, AbstractArray(n, Int.(domain_size)))
end
function (arrtype::Type{<:AbstractArray})(n::StateName, domain_size::Integer...)
  return arrtype(n, domain_size)
end
(arrtype::Type{<:AbstractArray})(n::StateName, ts::SiteType...) = arrtype(n, ts)
function Base.AbstractArray(n::StateName, ts::Tuple{Vararg{SiteType}})
  n′ = alias(n)
  ts′ = alias.(ts)
  if n′ == n && ts′ == ts
    return AbstractArray(n′, length.(ts′))
  end
  return AbstractArray(n′, ts′)
end
function Base.AbstractArray(n::StateName, domain_size::Tuple{Vararg{Int}})
  n′ = alias(n)
  if n′ == n
    error("Not implemented.")
  end
  return AbstractArray(n′, domain_size)
end

# TODO: Decide on this.
function Base.AbstractArray(n::StateName)
  return AbstractArray(n, ntuple(Returns(default_sitetype()), nsites(n)))
end
function (arrtype::Type{<:AbstractArray})(n::StateName)
  return arrtype(n, ntuple(Returns(default_sitetype()), nsites(n)))
end

function state(arrtype::Type{<:AbstractArray}, n::String, domain...; kwargs...)
  return arrtype(StateName(n; kwargs...), domain...)
end
function state(elt::Type{<:Number}, n::String, domain...; kwargs...)
  return state(AbstractArray{elt}, n, domain...; kwargs...)
end
function state(n::String, domain...; kwargs...)
  return state(AbstractArray, n, domain...; kwargs...)
end

# TODO: Add this.
## function Base.Integer(::StateName{N}) where {N}
##   return parse(Int, String(N))
## end

# TODO: Define as `::Tuple{Int}`.
function Base.AbstractArray(n::StateName{N}, domain_size::Tuple{Int}) where {N}
  # TODO: Use `Integer(n)`.
  n = parse(Int, String(N))
  a = falses(only(domain_size))
  a[n + 1] = one(Bool)
  return a
end
