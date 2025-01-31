module QuantumOperatorDefinitionsITensorBaseExt

using ITensorBase: ITensorBase, ITensor, Index, dag, gettag, prime
using NamedDimsArrays: dename
using QuantumOperatorDefinitions:
  QuantumOperatorDefinitions, OpName, SiteType, StateName, has_fermion_string

function QuantumOperatorDefinitions.SiteType(r::Index)
  # We pass the axis of the (unnamed) Index because
  # the Index may have originated from a slice, in which
  # case the start may not be 1 (and it may not even
  # be a unit range).
  return SiteType(
    gettag(r, "sitetype", "Qudit"); dim=Int.(length(r)), range=only(axes(dename(r)))
  )
end

function ITensorBase.Index(t::SiteType; kwargs...)
  return Index(AbstractUnitRange(t); kwargs...)
end

function QuantumOperatorDefinitions.has_fermion_string(n::String, r::Index)
  return has_fermion_string(OpName(n), SiteType(r))
end

function Base.AbstractArray(n::OpName, r::Index)
  # TODO: Define this with mapped dimnames.
  # Generalize beyond prime levels with codomain and domain indices.
  return ITensor(AbstractArray(n, SiteType(r)), (prime(r), dag(r)))
end

function Base.AbstractArray(n::StateName, r::Index)
  return ITensor(AbstractArray(n, SiteType(r)), (r,))
end

end
