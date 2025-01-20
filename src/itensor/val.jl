using ITensorBase: Index

function val(s::Index, name::AbstractString)::Int
  stypes = _sitetypes(s)
  sname = ValName(name)

  # Try calling val(::StateName"Name",::SiteType"Tag",)
  for st in stypes
    res = val(sname, st)
    !isnothing(res) && return res
  end

  return throw(
    ArgumentError("Overload of \"val\" function not found for Index tags $(tags(s))")
  )
end

val(s::Index, n::Integer) = n

val(sset::Vector{<:Index}, j::Integer, st) = val(sset[j], st)
