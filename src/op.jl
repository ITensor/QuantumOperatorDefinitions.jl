# TODO: Add `params<:NamedTuple` field.
struct OpName{Name} end
OpName(s::AbstractString) = OpName{Symbol(s)}()
OpName(s::Symbol) = OpName{s}()
name(::OpName{N}) where {N} = N
macro OpName_str(s)
  return OpName{Symbol(s)}
end

# Default implementations of op
op(::OpName; kwargs...) = nothing
op(::OpName, ::SiteType; kwargs...) = nothing

function _sitetypes(ts::Set)
  return collect(SiteType, SiteType.(ts))
end

op(name::AbstractString; kwargs...) = error("Must input indices when creating an `op`.")

# To ease calling of other op overloads,
# allow passing a string as the op name
op(opname::AbstractString, t::SiteType; kwargs...) = op(OpName(opname), t; kwargs...)

op(f::Function, args...; kwargs...) = f(op(args...; kwargs...))
