struct SiteType{T,Params}
  params::Params
end
params(t::SiteType) = getfield(t, :params)

Base.getproperty(t::SiteType, name::Symbol) = getfield(params(t), name)

SiteType{N}(params) where {N} = SiteType{N,typeof(params)}(params)
SiteType{N}(; kwargs...) where {N} = SiteType{N}((; kwargs...))

SiteType(s::AbstractString; kwargs...) = SiteType{Symbol(s)}(; kwargs...)
SiteType(i::Integer; kwargs...) = SiteType{Symbol(i)}(; kwargs...)
value(::SiteType{T}) where {T} = T
macro SiteType_str(s)
  return SiteType{Symbol(s)}
end
