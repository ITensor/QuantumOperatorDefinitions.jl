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

struct GradingType{T,Params}
  params::Params
  function GradingType{N}(params::NamedTuple) where {N}
    return new{N,typeof(params)}(params)
  end
end
name(::GradingType{T}) where {T} = T
params(t::GradingType) = getfield(t, :params)
Base.getproperty(t::GradingType, name::Symbol) = getfield(params(t), name)
Base.get(t::GradingType, name::Symbol, default) = get(params(t), name, default)
Base.haskey(t::GradingType, name::Symbol) = haskey(params(t), name)
GradingType{N}(; kwargs...) where {N} = GradingType{N}((; kwargs...))
GradingType(s::AbstractString; kwargs...) = GradingType{Symbol(s)}(; kwargs...)
function GradingType(s::Pair{<:AbstractString,<:AbstractString}; kwargs...)
  return GradingType(first(s); kwargs..., name=last(s))
end
function GradingType(s::Pair{<:AbstractString,<:NamedTuple}; kwargs...)
  return GradingType(first(s); kwargs..., last(s)...)
end
macro GradingType_str(s)
  return :(GradingType{$(Expr(:quote, Symbol(s)))})
end

function Base.AbstractUnitRange(grading::GradingType, t::SiteType)
  return error("Not implemented.")
end
function Base.AbstractUnitRange(grading::GradingType"Trivial", t::SiteType)
  return Base.OneTo(length(t))
end

function Base.length(t::SiteType)
  t′ = alias(t)
  if t == t′
    return t.dim
  end
  return length(t′)
end
# TODO: Use a shorthand `(t::SiteType)() = AbstractUnitRange(t)`,
# i.e. make `SiteType` callable like `OpName` and `StateName`
# are right now.
function Base.AbstractUnitRange(t::SiteType)
  # This logic allows specifying a range with extra properties,
  # like ones with symmetry sectors.
  haskey(t, :range) && return t.range
  if haskey(t, :gradings)
    rs = map(grading -> AbstractUnitRange(GradingType(grading), t), t.gradings)
    return combine_axes(Base.OneTo(length(t)), rs...)
  end
  return Base.OneTo(length(t))
end
# kwargs are passed for fancier constructors, like `ITensors.Index`.
function (rangetype::Type{<:AbstractUnitRange})(t::SiteType)
  return rangetype(AbstractUnitRange(t))
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

# TODO: Do we want to define this?
# (t::SiteType)() = AbstractUnitRange(t)

function site(rangetype::Type{<:AbstractUnitRange}, name::String; kwargs...)
  return rangetype(SiteType(name; kwargs...))
end
site(name::String; kwargs...) = site(AbstractUnitRange, name; kwargs...)

function sites(rangetype::Type{<:AbstractUnitRange}, name::String, positions; kwargs...)
  return map(position -> site(rangetype, name; site=position, kwargs...), positions)
end
function sites(
  rangetype::Type{<:AbstractUnitRange}, name::String, npositions::Integer; kwargs...
)
  return sites(rangetype, name, Base.OneTo(npositions); kwargs...)
end
function sites(name::String, positions; kwargs...)
  return sites(AbstractUnitRange, name, positions; kwargs...)
end
function sites(name::String, npositions::Integer; kwargs...)
  return sites(AbstractUnitRange, name, Base.OneTo(npositions); kwargs...)
end
