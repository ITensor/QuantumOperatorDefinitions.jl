module QuantumOperatorDefinitionsITensorBaseExt

using ITensorBase: ITensor, Index, dag, gettag, prime
using QuantumOperatorDefinitions:
  QuantumOperatorDefinitions, OpName, SiteType, StateName, has_fermion_string

function QuantumOperatorDefinitions.SiteType(r::Index)
  return SiteType(gettag(r, "sitetype", "Qudit"); dim=Int(length(r)))
end

function QuantumOperatorDefinitions.has_fermion_string(n::String, r::Index)
  return has_fermion_string(OpName(n), SiteType(r))
end

function Base.AbstractArray(n::OpName, r::Index)
  # TODO: Define this with mapped dimnames.
  return ITensor(AbstractArray(n, SiteType(r)), (prime(r), dag(r)))
end

function Base.AbstractArray(n::StateName, r::Index)
  return ITensor(AbstractArray(n, SiteType(r)), (r,))
end

end
