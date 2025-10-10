module QuantumOperatorDefinitionsGradedArraysExt

using BlockArrays: blocklasts, blocklength, blocklengths
using GradedArrays:
    AbstractGradedUnitRange, GradedOneTo, U1, Z, ×, dual, gradedrange, sectorproduct, sectors
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
    blocklength(a1) == blocklength(a2) ||
        throw(ArgumentError("Axes must have the same number of blocks."))
    nblocks = blocklength(a1)
    return gradedrange(
        map(Base.OneTo(nblocks)) do i
            l1 = blocklengths(a1)[i]
            l2 = blocklengths(a2)[i]
            l1 == l2 || throw(ArgumentError("Blocks must have the same length."))
            return sectors(a1)[i] × sectors(a2)[i] => l1
        end,
    )
end
QuantumOperatorDefinitions.combine_axes(a::GradedOneTo, b::Base.OneTo) = a
QuantumOperatorDefinitions.combine_axes(a::Base.OneTo, b::GradedOneTo) = b

function Base.AbstractUnitRange(::GradingType"N", t::SiteType)
    return gradedrange(map(i -> sectorproduct((; N = U1(i - 1))) => 1, 1:length(t)))
end
function Base.AbstractUnitRange(::GradingType"Sz", t::SiteType)
    return gradedrange(map(i -> sectorproduct((; Sz = U1(i - 1))) => 1, 1:length(t)))
end
function Base.AbstractUnitRange(::GradingType"Sz↑", t::SiteType)
    return AbstractUnitRange(GradingType"Sz"(), t)
end
function Base.AbstractUnitRange(::GradingType"Sz↓", t::SiteType)
    return gradedrange(map(i -> sectorproduct((; Sz = U1(-(i - 1)))) => 1, 1:length(t)))
end

function sector(gradingtype::GradingType, sec)
    sectorname = Symbol(get(gradingtype, :name, name(gradingtype)))
    return sectorproduct(NamedTuple{(sectorname,)}((sec,)))
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
    return gradedrange(
        [
            sector(s, U1(0)) => 1,
            sector(s, U1(1)) => 1,
            sector(s, U1(1)) => 1,
            sector(s, U1(2)) => 1,
        ]
    )
end
# TODO: Write in terms of `GradingType"Nf"` definition.
function Base.AbstractUnitRange(s::GradingType"NfParity", t::SiteType"Electron")
    return gradedrange(
        [
            sector(s, Z{2}(0)) => 1,
            sector(s, Z{2}(1)) => 1,
            sector(s, Z{2}(1)) => 1,
            sector(s, Z{2}(0)) => 1,
        ]
    )
end
function Base.AbstractUnitRange(s::GradingType"Sz", t::SiteType"Electron")
    return gradedrange(
        [
            sector(s, U1(0)) => 1,
            sector(s, U1(1)) => 1,
            sector(s, U1(-1)) => 1,
            sector(s, U1(0)) => 1,
        ]
    )
end

end
