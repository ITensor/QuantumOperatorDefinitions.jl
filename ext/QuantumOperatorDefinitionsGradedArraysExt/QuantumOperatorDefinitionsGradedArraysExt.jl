module QuantumOperatorDefinitionsGradedArraysExt

using BlockArrays: blocklasts, blocklengths
using GradedArrays: AbstractGradedUnitRange, GradedOneTo, SectorProduct, U1, Z, ×, dual, gradedrange
using QuantumOperatorDefinitions:
  QuantumOperatorDefinitions,
  @GradingType_str,
  @SiteType_str,
  GradingType,
  OpName,
  SiteType,
  name

function Base.axes(::OpName, domain::Tuple{Vararg{AbstractGradedUnitRange}})
  return (domain..., dual.(domain)...)
end

sortedunion(a, b) = sort(union(a, b))
function QuantumOperatorDefinitions.combine_axes(a1::GradedOneTo, a2::GradedOneTo)
  return gradedrange(
    map(blocklengths(a1), blocklengths(a2)) do s1, s2
      l1 = unlabel(s1)
      l2 = unlabel(s2)
      @assert l1 == l2
      labelled(l1, label(s1) × label(s2))
    end,
  )
end
QuantumOperatorDefinitions.combine_axes(a::GradedOneTo, b::Base.OneTo) = a
QuantumOperatorDefinitions.combine_axes(a::Base.OneTo, b::GradedOneTo) = b

function Base.AbstractUnitRange(::GradingType"N", t::SiteType)
  return gradedrange(map(i -> SectorProduct((; N=U1(i - 1))) => 1, 1:length(t)))
end
function Base.AbstractUnitRange(::GradingType"Sz", t::SiteType)
  return gradedrange(map(i -> SectorProduct((; Sz=U1(i - 1))) => 1, 1:length(t)))
end
function Base.AbstractUnitRange(::GradingType"Sz↑", t::SiteType)
  return AbstractUnitRange(GradingType"Sz"(), t)
end
function Base.AbstractUnitRange(::GradingType"Sz↓", t::SiteType)
  return gradedrange(map(i -> SectorProduct((; Sz=U1(-(i - 1)))) => 1, 1:length(t)))
end

function sector(gradingtype::GradingType, sec)
  sectorname = Symbol(get(gradingtype, :name, name(gradingtype)))
  return SectorProduct(NamedTuple{(sectorname,)}((sec,)))
end

function Base.AbstractUnitRange(s::GradingType"Nf", t::SiteType"Fermion")
  return gradedrange([sector(s, U1(0)) => 1, sector(s, U1(1)) => 1])
end
# TODO: Write in terms of `GradingType"Nf"` definition.
function Base.AbstractUnitRange(s::GradingType"NfParity", t::SiteType"Fermion")
  return gradedrange([sector(s, Z{2}(0)) => 1, sector(s, Z{2}(1)) => 1])
end
function Base.AbstractUnitRange(s::GradingType"Sz", t::SiteType"Fermion")
  return gradedrange([sector(s, U1(0)) => 1, sector(s, U1(1)) => 1])
end
function Base.AbstractUnitRange(s::GradingType"Sz↑", t::SiteType"Fermion")
  return gradedrange([sector(s, U1(0)) => 1, sector(s, U1(1)) => 1])
end
function Base.AbstractUnitRange(s::GradingType"Sz↓", t::SiteType"Fermion")
  return gradedrange([sector(s, U1(0)) => 1, sector(s, U1(-1)) => 1])
end

# TODO: Write in terms of `SiteType"Fermion"` definitions.
function Base.AbstractUnitRange(s::GradingType"Nf", t::SiteType"Electron")
  return gradedrange([
    sector(s, U1(0)) => 1,
    sector(s, U1(1)) => 1,
    sector(s, U1(1)) => 1,
    sector(s, U1(2)) => 1,
  ])
end
# TODO: Write in terms of `GradingType"Nf"` definition.
function Base.AbstractUnitRange(s::GradingType"NfParity", t::SiteType"Electron")
  return gradedrange([
    sector(s, Z{2}(0)) => 1,
    sector(s, Z{2}(1)) => 1,
    sector(s, Z{2}(1)) => 1,
    sector(s, Z{2}(0)) => 1,
  ])
end
function Base.AbstractUnitRange(s::GradingType"Sz", t::SiteType"Electron")
  return gradedrange([
    sector(s, U1(0)) => 1,
    sector(s, U1(1)) => 1,
    sector(s, U1(-1)) => 1,
    sector(s, U1(0)) => 1,
  ])
end

end
