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
