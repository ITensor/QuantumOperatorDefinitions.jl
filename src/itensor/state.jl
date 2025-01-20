using ITensorBase: ITensor, Index, onehot

state(::StateName, ::SiteType, ::Index; kwargs...) = nothing

# Syntax `state("Up", Index(2, "S=1/2"))`
state(sn::String, i::Index; kwargs...) = state(i, sn; kwargs...)

function state(s::Index, name::AbstractString; kwargs...)::ITensor
  stypes = _sitetypes(s)
  sname = StateName(name)
  for st in stypes
    v = state(sname, st; kwargs...)
    !isnothing(v) && return ITensor(v, (s,))
  end
  return throw(
    ArgumentError(
      "Overload of \"state\" functions not found for state name \"$name\" and Index tags $(tags(s))",
    ),
  )
end

state(s::Index, n::Integer) = onehot(s => n)

state(sset::Vector{<:Index}, j::Integer, st; kwargs...) = state(sset[j], st; kwargs...)
