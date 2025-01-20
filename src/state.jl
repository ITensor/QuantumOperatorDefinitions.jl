@eval struct StateName{Name}
  (f::Type{<:StateName})() = $(Expr(:new, :f))
end

StateName(s::AbstractString) = StateName{Symbol(s)}()
StateName(s::Symbol) = StateName{s}()
name(::StateName{N}) where {N} = N

macro StateName_str(s)
  return StateName{Symbol(s)}
end

state(::StateName, ::SiteType; kwargs...) = nothing
