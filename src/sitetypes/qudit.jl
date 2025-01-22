Base.length(t::SiteType"Qudit") = t.length

# TODO: Add this.
## function Base.Integer(::StateName{N}) where {N}
##   return parse(Int, String(N))
## end

function Base.AbstractArray(n::StateName{N}, ::Tuple{SiteType"Qudit"}) where {N}
  # TODO: Use `Integer(n)`.
  n = parse(Int, String(N))
  a = falses(dim(s))
  a[n + 1] = one(Bool)
  return a
end

function Base.AbstractArray(n::OpName"a†", t::Tuple{SiteType"Qudit"})
  d = length(t)
  a = zeros(d, d)
  for k in 1:(d - 1)
    a[k + 1, k] = √k
  end
  return a
end
@op_alias "Adag" "a†"
@op_alias "adag" "a†"

alias(::OpName"a") = OpName"a†"()'
@op_alias "A" "a"

alias(::OpName"n") = OpName"a†"() * OpName"a"()
@op_alias "N" "n"

alias(::OpName"aa") = OpName("a") ⊗ OpName("a")
alias(::OpName"a†a") = OpName("a†") ⊗ OpName("a")
alias(::OpName"aa†") = OpName("a") ⊗ OpName("a†")
alias(::OpName"a†a†") = OpName("a†") ⊗ OpName("a†")
