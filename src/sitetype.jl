struct SiteType{T,Params}
  params::Params
  function SiteType{N}(params::NamedTuple) where {N}
    return new{N,typeof(params)}(params)
  end
end
name(::SiteType{T}) where {T} = T
params(t::SiteType) = getfield(t, :params)
Base.getproperty(t::SiteType, name::Symbol) = getfield(params(t), name)
Base.get(t::SiteType, name::Symbol, default) = get(params(t), name, default)
Base.haskey(t::SiteType, name::Symbol) = haskey(params(t), name)
SiteType{N}(; kwargs...) where {N} = SiteType{N}((; kwargs...))
SiteType(s::AbstractString; kwargs...) = SiteType{Symbol(s)}(; kwargs...)
SiteType(i::Integer; kwargs...) = SiteType{Symbol(i)}(; kwargs...)
macro SiteType_str(s)
  return :(SiteType{$(Expr(:quote, Symbol(s)))})
end

alias(t::SiteType) = t
alias(i::Integer) = i

# Like `Base.Broadcast.axistype` (https://github.com/JuliaLang/julia/blob/v1.11.3/base/broadcast.jl#L536-L538)
# and `BlockArrays.combine_blockaxes` (https://github.com/JuliaArrays/BlockArrays.jl/blob/v1.3.0/src/blockbroadcast.jl#L37-L38).
combine_axes(a::T, b::T) where {T} = a
combine_axes(a::Base.OneTo, b::Base.OneTo) = Base.OneTo{Int}(a)
function combine_axes(a, b)
  return UnitRange{Int}(a)
end
combine_axes(a) = a
combine_axes(a, b, rest...) = combine_axes(combine_axes(a, b), rest...)

struct SymmetryType{T,Params}
  params::Params
  function SymmetryType{N}(params::NamedTuple) where {N}
    return new{N,typeof(params)}(params)
  end
end
name(::SymmetryType{T}) where {T} = T
params(t::SymmetryType) = getfield(t, :params)
Base.getproperty(t::SymmetryType, name::Symbol) = getfield(params(t), name)
Base.get(t::SymmetryType, name::Symbol, default) = get(params(t), name, default)
Base.haskey(t::SymmetryType, name::Symbol) = haskey(params(t), name)
SymmetryType{N}(; kwargs...) where {N} = SymmetryType{N}((; kwargs...))
SymmetryType(s::AbstractString; kwargs...) = SymmetryType{Symbol(s)}(; kwargs...)
function SymmetryType(s::Pair{<:AbstractString,<:AbstractString}; kwargs...)
  return SymmetryType(first(s); kwargs..., name=last(s))
end
function SymmetryType(s::Pair{<:AbstractString,<:NamedTuple}; kwargs...)
  return SymmetryType(first(s); kwargs..., last(s)...)
end
macro SymmetryType_str(s)
  return :(SymmetryType{$(Expr(:quote, Symbol(s)))})
end

function Base.AbstractUnitRange(symmetry::SymmetryType, t::SiteType)
  return error("Not implemented.")
end
function Base.AbstractUnitRange(symmetry::SymmetryType"Trivial", t::SiteType)
  return Base.OneTo(length(t))
end

function Base.length(t::SiteType)
  t′ = alias(t)
  if t == t′
    return t.dim
  end
  return length(t′)
end
function Base.AbstractUnitRange(t::SiteType)
  # This logic allows specifying a range with extra properties,
  # like ones with symmetry sectors.
  haskey(t, :range) && return t.range
  if haskey(t, :symmetries)
    rs = map(symmetry -> AbstractUnitRange(SymmetryType(symmetry), t), t.symmetries)
    return combine_axes(Base.OneTo(length(t)), rs...)
  end
  return Base.OneTo(length(t))
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
