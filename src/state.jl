using Random: randstring

struct StateName{Name,Params}
  params::Params
  function StateName{N}(params::NamedTuple) where {N}
    return new{N,typeof(params)}(params)
  end
end
params(n::StateName) = getfield(n, :params)
Base.getproperty(n::StateName, name::Symbol) = getfield(params(n), name)

StateName{N}(; kwargs...) where {N} = StateName{N}((; kwargs...))

StateName(s::AbstractString; kwargs...) = StateName{Symbol(s)}(; kwargs...)
StateName(s::Symbol; kwargs...) = StateName{s}(; kwargs...)
name(::StateName{N}) where {N} = N
macro StateName_str(s)
  return StateName{Symbol(s)}
end

# Handles special case `state(1) == [1, 0]`. Note the
# one-based indexing, as opposed to `state("0") == [1, 0]`.
StateName(i::Integer; kwargs...) = StateName"StandardBasis"(; index=i, kwargs...)

function state_alias_expr(name1, name2, pars...)
  return :(function alias(n::StateName{Symbol($name1)})
    return StateName{Symbol($name2)}(; params(n)..., $(esc.(pars)...))
  end)
end
macro state_alias(name1, name2, params...)
  return state_alias_expr(name1, name2)
end

function (arrtype::Type{<:AbstractArray})(n::StateName, domain::Tuple{Vararg{SiteType}})
  # TODO: Define `state_convert` to handle reshaping multisite states
  # to higher order arrays.
  return convert(arrtype, n(domain...))
end
function (arrtype::Type{<:AbstractArray})(n::StateName, domain::Tuple{Vararg{Integer}})
  # TODO: Define `state_convert` to handle reshaping multisite states
  # to higher order arrays.
  return convert(arrtype, n(Int.(domain)...))
end

# This compiles operator expressions, such as:
# ```julia
# stateexpr("0 + 1") == StateName("0") + StateName("1")
# ```
function stateexpr(n::String; kwargs...)
  return state_or_op_expr(StateName, n; kwargs...)
end

# Handles special case `state(1) == [1, 0]`. Note the
# one-based indexing, as opposed to `state("0") == [1, 0]`.
stateexpr(n::Integer; kwargs...) = StateName(n; kwargs...)

randcharstring() = randstring(['A':'Z'; 'a':'z'], 12)
const DAGGER_STRING = randcharstring()
const UPARROW_STRING = randcharstring()
const DOWNARROW_STRING = randcharstring()
const PLUS_STRING = randcharstring()
const MINUS_STRING = randcharstring()
const VERTICALBAR_STRING = randcharstring()
const RANGLE_STRING = randcharstring()
const EXPR_REPLACEMENTS_1 = (
  "†" => DAGGER_STRING,
  "↑" => UPARROW_STRING,
  "↓" => DOWNARROW_STRING,
  # Replace trailing plus and minus characters
  # in operators, which don't parse properly.
  r"(\S)\+" => SubstitutionString("\\1$(PLUS_STRING)"),
  r"(\S)\-" => SubstitutionString("\\1$(MINUS_STRING)"),
)
const EXPR_REPLACEMENTS_2 = (
  r"\|(\S*)⟩" => SubstitutionString("$(VERTICALBAR_STRING)\\1$(RANGLE_STRING)"),
)
const INVERSE_EXPR_REPLACEMENTS = (
  DAGGER_STRING => "†",
  UPARROW_STRING => "↑",
  DOWNARROW_STRING => "↓",
  PLUS_STRING => "+",
  MINUS_STRING => "-",
  # We remove the bra-ket notation and search for states
  # with names stored inside.
  VERTICALBAR_STRING => "",
  RANGLE_STRING => "",
)

function state_or_op_expr(ntype::Type, n::String; kwargs...)
  # Do this in two rounds since for some reason
  # one round doesn't work for expressions
  # like `"|+⟩"`.
  n = replace(n, EXPR_REPLACEMENTS_1...)
  n = replace(n, EXPR_REPLACEMENTS_2...)
  depth = 1
  return state_or_op_expr(ntype, Meta.parse(n), depth; kwargs...)
end
function state_or_op_expr(ntype::Type, n::Number, depth::Int; kwargs...)
  if depth == 1
    return ntype{Symbol(n)}(; kwargs...)
  end
  return n
end
function state_or_op_expr(ntype::Type, n::Symbol, depth::Int; kwargs...)
  n === :im && return im
  n === :π && return π
  n = Symbol(replace(String(n), INVERSE_EXPR_REPLACEMENTS...))
  return ntype{n}(; kwargs...)
end
function state_or_op_expr(ntype::Type, ex::Expr, depth::Int)
  if Meta.isexpr(ex, :call)
    return eval(ex.args[1])(state_or_op_expr.(ntype, ex.args[2:end], depth + 1)...)
  end
  if Meta.isexpr(ex, :curly)
    # Syntax for parametrized gates, i.e.
    # `state_or_op_expr("Ry{θ=π/2}")`.
    params = ex.args[2:end]
    kwargs = Dict(
      map(params) do param
        @assert Meta.isexpr(param, :(=))
        return param.args[1] => eval(param.args[2])
      end,
    )
    return ntype{ex.args[1]}(; kwargs...)
  end
  return error("Can't parse expression $ex.")
end

function state(arrtype::Type{<:AbstractArray}, n::Union{Int,String}, domain...; kwargs...)
  return arrtype(stateexpr(n; kwargs...), domain...)
end
function state(elt::Type{<:Number}, n::Union{Int,String}, domain...; kwargs...)
  return state(AbstractArray{elt}, n, domain...; kwargs...)
end
function state(n::Union{Int,String}, domain...; kwargs...)
  return state(AbstractArray, n, domain...; kwargs...)
end

function (n::StateName"StandardBasis")(domain)
  a = falses(to_dim(domain))
  a[n.index] = one(Bool)
  return a
end
function (n::StateName{N})(domain...) where {N}
  # TODO: Try one alias at a time?
  # TODO: First call `alias(n, domain...)`
  # to allow for aliases specific to certain
  # SiteTypes?
  n′ = alias(n)
  domain′ = alias.(domain)
  if n == n′ && domain′ == domain
    index = parse(Int, String(N)) + 1
    return StateName"StandardBasis"(; index)(domain...)
  end
  return n′(domain′...)
end
