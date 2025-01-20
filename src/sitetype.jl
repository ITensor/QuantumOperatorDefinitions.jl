using ChainRulesCore: @ignore_derivatives

# TODO: Need to define or replace.
# using ITensorBase: product, swapprime

# TODO: Add `params<:NamedTuple` field.
struct SiteType{T} end
SiteType(s::AbstractString) = SiteType{Symbol(s)}()
SiteType(i::Integer) = SiteType{Symbol(i)}()
value(::SiteType{T}) where {T} = T
macro SiteType_str(s)
  return SiteType{Symbol(s)}
end
