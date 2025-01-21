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

# TODO: Bring this back?
## state(::StateName, ::SiteType; kwargs...) = nothing
