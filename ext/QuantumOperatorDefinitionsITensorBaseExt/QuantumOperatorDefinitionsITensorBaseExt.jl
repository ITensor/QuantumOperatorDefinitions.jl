module QuantumOperatorDefinitionsITensorBaseExt

using ITensorBase: ITensorBase, ITensor, Index, gettag, prime, settag
using GradedArrays: dual
using NamedDimsArrays: dename
using QuantumOperatorDefinitions:
    QuantumOperatorDefinitions,
    @OpName_str,
    OpName,
    SiteType,
    StateName,
    has_fermion_string,
    name

function QuantumOperatorDefinitions.SiteType(r::Index)
    # We pass the axis of the (unnamed) Index because
    # the Index may have originated from a slice, in which
    # case the start may not be 1 (for NonContiguousIndex,
    # which we need to add support for, it may not even
    # be a unit range).
    return SiteType(
        gettag(r, "sitetype", "Qudit"); dim = Int.(length(r)), range = only(axes(dename(r)))
    )
end

function (rangetype::Type{<:Index})(t::SiteType)
    i = rangetype(AbstractUnitRange(t))
    i = settag(i, "sitetype", String(name(t)))
    if haskey(t, :site)
        i = settag(i, "site", string(t.site))
    end
    return i
end

# TODO: Define in terms of `OpName` directly, and define a generic
# forwarding method `has_fermion_string(n::String, t) = has_fermion_string(OpName(n), t)`.
function QuantumOperatorDefinitions.has_fermion_string(n::String, r::Index)
    return has_fermion_string(OpName(n), SiteType(r))
end

function Base.axes(::OpName, domain::Tuple{Vararg{Index}})
    return (prime.(domain)..., dual.(domain)...)
end
## function Base.axes(::OpName"SWAP", domain::Tuple{Vararg{Index}})
##   return (prime.(reverse(domain))..., dag.(domain)...)
## end

# Fix ambiguity error with generic `AbstractArray` version.
function ITensorBase.ITensor(n::Union{OpName, StateName}, domain::Index...)
    return ITensor(n, domain)
end
# Fix ambiguity error with generic `AbstractArray` version.
function ITensorBase.ITensor(n::Union{OpName, StateName}, domain::Tuple{Vararg{Index}})
    return ITensor(AbstractArray(n, domain), axes(n, domain))
end
function (arrtype::Type{<:AbstractArray})(
        n::Union{OpName, StateName}, domain::Tuple{Vararg{Index}}
    )
    # Convert to `SiteType` in case the Index specifies a `"sitetype"` tag.
    # TODO: Try to build this into the generic codepath.
    return ITensor(arrtype(n, SiteType.(domain)), axes(n, domain))
end

end
