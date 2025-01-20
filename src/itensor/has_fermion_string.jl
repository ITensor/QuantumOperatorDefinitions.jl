using ITensorBase: Index

has_fermion_string(operator::AbstractArray{<:Number}, s::Index; kwargs...)::Bool = false

function has_fermion_string(opname::AbstractString, s::Index; kwargs...)::Bool
  opname = strip(opname)

  # Interpret operator names joined by *
  # as acting sequentially on the same site
  starpos = findfirst(isequal('*'), opname)
  if !isnothing(starpos)
    op1 = opname[1:prevind(opname, starpos)]
    op2 = opname[nextind(opname, starpos):end]
    return xor(has_fermion_string(op1, s; kwargs...), has_fermion_string(op2, s; kwargs...))
  end

  Ntags = length(tags(s))
  stypes = _sitetypes(s)
  opn = OpName(opname)
  for st in stypes
    res = has_fermion_string(opn, st)
    !isnothing(res) && return res
  end
  return false
end
