struct SiteType{T,Params}
  params::Params
  function SiteType{N}(params::NamedTuple) where {N}
    return new{N,typeof(params)}(params)
  end
end
value(::SiteType{T}) where {T} = T
params(t::SiteType) = getfield(t, :params)
Base.getproperty(t::SiteType, name::Symbol) = getfield(params(t), name)
Base.get(t::SiteType, name::Symbol, default) = get(params(t), name, default)

SiteType{N}(; kwargs...) where {N} = SiteType{N}((; kwargs...))

SiteType(s::AbstractString; kwargs...) = SiteType{Symbol(s)}(; kwargs...)
SiteType(i::Integer; kwargs...) = SiteType{Symbol(i)}(; kwargs...)
macro SiteType_str(s)
  return SiteType{Symbol(s)}
end

alias(t::SiteType) = t
alias(i::Integer) = i

function Base.length(t::SiteType)
  t′ = alias(t)
  if t == t′
    return t.length
  end
  return length(t′)
end
function Base.AbstractUnitRange(t::SiteType)
  # This logic allows specifying a range with extra properties,
  # like ones with symmetry sectors.
  return get(t, :range, Base.OneTo(length(t)))
end
Base.size(t::SiteType) = (length(t),)
Base.size(t::SiteType, dim::Integer) = size(t)[dim]
Base.axes(t::SiteType) = (AbstractUnitRange(t),)
Base.axes(t::SiteType, dim::Integer) = axes(t)[dim]

to_dim(d::Base.OneTo) = length(d)
to_dim(d::SiteType) = length(d)
to_dim(d::Integer) = d

# TODO: Decide on this.
# TODO: Move to `sitetype.jl`.
default_sitetype() = SiteType"Qubit"()
