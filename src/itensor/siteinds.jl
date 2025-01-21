using ITensorBase: Index, addtags

function siteind(st::SiteType; addtags="")
  # TODO: Generalize to ranges, QNs.
  sp = length(st)
  isnothing(sp) && return nothing
  return Index(sp, "Site, $(value(st)), $addtags")
end

function siteind(st::SiteType, n; kwargs...)
  s = siteind(st; kwargs...)
  !isnothing(s) && return addtags(s, "n=$n")
  sp = space(st, n; kwargs...)
  isnothing(sp) && error(space_error_message(st))
  return Index(sp, "Site, $(value(st)), n=$n")
end

siteind(tag::String; kwargs...) = siteind(SiteType(tag); kwargs...)

siteind(tag::String, n; kwargs...) = siteind(SiteType(tag), n; kwargs...)

# Special case of `siteind` where integer (dim) provided
# instead of a tag string
#siteind(d::Integer, n::Integer; kwargs...) = Index(d, "Site,n=$n")
function siteind(d::Integer, n::Integer; addtags="", kwargs...)
  return Index(d, "Site,n=$n, $addtags")
end

siteinds(::SiteType, N; kwargs...) = nothing

"""
    siteinds(tag::String, N::Integer; kwargs...)

Create an array of `N` physical site indices of type `tag`.
Keyword arguments can be used to specify quantum number conservation,
see the `space` function corresponding to the site type `tag` for
supported keyword arguments.

# Example

```julia
N = 10
s = siteinds("S=1/2", N; conserve_qns=true)
```
"""
function siteinds(tag::String, N::Integer; kwargs...)
  st = SiteType(tag)

  si = siteinds(st, N; kwargs...)
  if !isnothing(si)
    return si
  end

  return [siteind(st, j; kwargs...) for j in 1:N]
end

"""
    siteinds(f::Function, N::Integer; kwargs...)

Create an array of `N` physical site indices where the site type at site `n` is given
by `f(n)` (`f` should return a string).
"""
function siteinds(f::Function, N::Integer; kwargs...)
  return [siteind(f(n), n; kwargs...) for n in 1:N]
end

# Special case of `siteinds` where integer (dim)
# provided instead of a tag string
"""
    siteinds(d::Integer, N::Integer; kwargs...)

Create an array of `N` site indices, each of dimension `d`.

# Keywords
- `addtags::String`: additional tags to be added to all indices
"""
function siteinds(d::Integer, N::Integer; kwargs...)
  return [siteind(d, n; kwargs...) for n in 1:N]
end
