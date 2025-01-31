module QuantumOperatorDefinitionsSymmetrySectorsExt

using BlockArrays: blocklasts, blocklengths
using GradedUnitRanges: GradedOneTo, gradedrange
using LabelledNumbers: label, labelled, unlabel
using QuantumOperatorDefinitions:
  QuantumOperatorDefinitions, @SiteType_str, @SymmetryType_str, SiteType, SymmetryType, name
using SymmetrySectors: ×, SectorProduct, U1, Z

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

function Base.AbstractUnitRange(::SymmetryType"N", t::SiteType)
  return gradedrange(map(i -> SectorProduct((; N=U1(i - 1))) => 1, 1:length(t)))
end
function Base.AbstractUnitRange(::SymmetryType"Sz", t::SiteType)
  return gradedrange(map(i -> SectorProduct((; Sz=U1(i - 1))) => 1, 1:length(t)))
end
function Base.AbstractUnitRange(::SymmetryType"Sz↑", t::SiteType)
  return AbstractUnitRange(SymmetryType"Sz"(), t)
end
function Base.AbstractUnitRange(::SymmetryType"Sz↓", t::SiteType)
  return gradedrange(map(i -> SectorProduct((; Sz=U1(-(i - 1)))) => 1, 1:length(t)))
end

function sector(symmetrytype::SymmetryType, sec)
  sectorname = Symbol(get(symmetrytype, :name, name(symmetrytype)))
  return SectorProduct(NamedTuple{(sectorname,)}((sec,)))
end

function Base.AbstractUnitRange(s::SymmetryType"Nf", t::SiteType"Fermion")
  return gradedrange([sector(s, U1(0)) => 1, sector(s, U1(1)) => 1])
end
# TODO: Write in terms of `SymmetryType"Nf"` definition.
function Base.AbstractUnitRange(s::SymmetryType"NfParity", t::SiteType"Fermion")
  return gradedrange([sector(s, Z{2}(0)) => 1, sector(s, Z{2}(1)) => 1])
end
function Base.AbstractUnitRange(s::SymmetryType"Sz", t::SiteType"Fermion")
  return gradedrange([sector(s, U1(0)) => 1, sector(s, U1(1)) => 1])
end
function Base.AbstractUnitRange(s::SymmetryType"Sz↑", t::SiteType"Fermion")
  return gradedrange([sector(s, U1(0)) => 1, sector(s, U1(1)) => 1])
end
function Base.AbstractUnitRange(s::SymmetryType"Sz↓", t::SiteType"Fermion")
  return gradedrange([sector(s, U1(0)) => 1, sector(s, U1(-1)) => 1])
end

# TODO: Write in terms of `SiteType"Fermion"` definitions.
function Base.AbstractUnitRange(s::SymmetryType"Nf", t::SiteType"Electron")
  return gradedrange([
    sector(s, U1(0)) => 1,
    sector(s, U1(1)) => 1,
    sector(s, U1(1)) => 1,
    sector(s, U1(2)) => 1,
  ])
end
# TODO: Write in terms of `SymmetryType"Nf"` definition.
function Base.AbstractUnitRange(s::SymmetryType"NfParity", t::SiteType"Electron")
  return gradedrange([
    sector(s, Z{2}(0)) => 1,
    sector(s, Z{2}(1)) => 1,
    sector(s, Z{2}(1)) => 1,
    sector(s, Z{2}(0)) => 1,
  ])
end
function Base.AbstractUnitRange(s::SymmetryType"Sz", t::SiteType"Electron")
  return gradedrange([
    sector(s, U1(0)) => 1,
    sector(s, U1(1)) => 1,
    sector(s, U1(-1)) => 1,
    sector(s, U1(0)) => 1,
  ])
end

end
