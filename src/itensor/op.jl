using ITensorBase: Index, ITensor, dag, prime, tags

op(::OpName, ::SiteType, ::Index...; kwargs...) = nothing
function op(
  ::OpName, ::SiteType, ::SiteType, sitetypes_inds::Union{SiteType,Index}...; kwargs...
)
  return nothing
end

_sitetypes(i::Index) = _sitetypes(tags(i))

function commontags(i::Index...)
  return union(tags.(i)...)
end

op(X::AbstractArray, s::Index...) = ITensor(X, (prime.(s)..., dag.(s)...))

# TODO: Delete these.
op(opname, s::Vector{<:Index}; kwargs...) = op(opname, s...; kwargs...)
op(s::Vector{<:Index}, opname; kwargs...) = op(opname, s...; kwargs...)

function op(name::AbstractString, s::Index...; adjoint::Bool=false, kwargs...)
  name = strip(name)
  # TODO: filter out only commons tags
  # if there are multiple indices
  commontags_s = commontags(s...)
  # first we handle the + and - algebra, which requires a space between ops to avoid clashing
  name_split = nothing
  @ignore_derivatives name_split = String.(split(name, " "))
  oplocs = findall(x -> x ∈ ("+", "-"), name_split)
  if !isempty(oplocs)
    @ignore_derivatives !isempty(kwargs) &&
      error("Lazy algebra on parametric gates not allowed")
    # the string representation of algebra ops: ex ["+", "-", "+"]
    labels = name_split[oplocs]
    # assign coefficients to each term: ex [+1, -1, +1]
    coeffs = [1, [(-1)^Int(label == "-") for label in labels]...]
    # grad the name of each operator block separated by an algebra op, and do so by
    # making sure blank spaces between opnames are kept when building the new block.
    start, opnames = 0, String[]
    for oploc in oplocs
      finish = oploc
      opnames = vcat(
        opnames, [prod([name_split[k] * " " for k in (start + 1):(finish - 1)])]
      )
      start = oploc
    end
    opnames = vcat(
      opnames, [prod([name_split[k] * " " for k in (start + 1):length(name_split)])]
    )
    # build the vector of blocks and sum
    op_list = [
      coeff * (op(opname, s...; kwargs...)) for (coeff, opname) in zip(coeffs, opnames)
    ]
    return sum(op_list)
  end
  # the the multiplication come after
  oploc = findfirst("*", name)
  if !isnothing(oploc)
    op1, op2 = nothing, nothing
    @ignore_derivatives begin
      op1 = name[1:prevind(name, oploc.start)]
      op2 = name[nextind(name, oploc.start):end]
      if !(op1[end] == ' ' && op2[1] == ' ')
        @warn "($op1*$op2) composite op definition `A*B` deprecated: please use `A * B` instead (with spaces)"
      end
    end
    return product(op(op1, s...; kwargs...), op(op2, s...; kwargs...))
  end
  common_stypes = _sitetypes(commontags_s)
  @ignore_derivatives push!(common_stypes, SiteType("Generic"))
  opn = OpName(name)
  for st in common_stypes
    op_mat = op(opn, st; kwargs...)
    if !isnothing(op_mat)
      rs = reverse(s)
      res = ITensor(op_mat, (prime.(rs)..., dag.(rs)...))
      adjoint && return swapprime(dag(res), 0 => 1)
      return res
    end
  end
  return throw(
    ArgumentError(
      "Overload of \"op\" or \"op!\" functions not found for operator name \"$name\" and Index tags: $(tags.(s)).",
    ),
  )
end

function op(opname, s::Vector{<:Index}, ns::NTuple{N,Integer}; kwargs...) where {N}
  return op(opname, ntuple(n -> s[ns[n]], Val(N))...; kwargs...)
end

function op(opname, s::Vector{<:Index}, ns::Vararg{Integer}; kwargs...)
  return op(opname, s, ns; kwargs...)
end

function op(s::Vector{<:Index}, opname, ns::Tuple{Vararg{Integer}}; kwargs...)
  return op(opname, s, ns...; kwargs...)
end

function op(s::Vector{<:Index}, opname, ns::Integer...; kwargs...)
  return op(opname, s, ns; kwargs...)
end

function op(s::Vector{<:Index}, opname, ns::Tuple{Vararg{Integer}}, kwargs::NamedTuple)
  return op(opname, s, ns; kwargs...)
end

function op(s::Vector{<:Index}, opname, ns::Integer, kwargs::NamedTuple)
  return op(opname, s, (ns,); kwargs...)
end

op(s::Vector{<:Index}, o::Tuple) = op(s, o...)

op(o::Tuple, s::Vector{<:Index}) = op(s, o...)

function op(
  s::Vector{<:Index},
  f::Function,
  opname::AbstractString,
  ns::Tuple{Vararg{Integer}};
  kwargs...,
)
  return f(op(opname, s, ns...; kwargs...))
end

function op(
  s::Vector{<:Index}, f::Function, opname::AbstractString, ns::Integer...; kwargs...
)
  return f(op(opname, s, ns; kwargs...))
end

# Here, Ref is used to not broadcast over the vector of indices
# TODO: consider overloading broadcast for `op` with the example
# here: https://discourse.julialang.org/t/how-to-broadcast-over-only-certain-function-arguments/19274/5
# so that `Ref` isn't needed.
ops(s::Vector{<:Index}, os::AbstractArray) = [op(oₙ, s) for oₙ in os]
ops(os::AbstractVector, s::Vector{<:Index}) = [op(oₙ, s) for oₙ in os]
