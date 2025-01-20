@eval struct ValName{Name}
  (f::Type{<:ValName})() = $(Expr(:new, :f))
end

ValName(s::AbstractString) = ValName{Symbol(s)}()
ValName(s::Symbol) = ValName{s}()
name(::ValName{N}) where {N} = N

macro ValName_str(s)
  return ValName{Symbol(s)}
end

val(::ValName, ::SiteType) = nothing
val(::AbstractString, ::SiteType) = nothing
