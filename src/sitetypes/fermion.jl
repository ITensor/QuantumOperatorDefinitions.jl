Base.length(::SiteType"Fermion") = 2

Base.AbstractArray(::StateName"Emp", ::SiteType"Fermion") = [1.0 0.0]
Base.AbstractArray(::StateName"Occ", ::SiteType"Fermion") = [0.0 1.0]
function Base.AbstractArray(::StateName"0", st::SiteType"Fermion")
  return AbstractArray(StateName("Emp"), st)
end
function Base.AbstractArray(::StateName"1", st::SiteType"Fermion")
  return AbstractArray(StateName("Occ"), st)
end

function Base.AbstractArray(::OpName"F", ::Tuple{SiteType"Fermion"})
  return [
    1 0
    0 -1
  ]
end

@op_alias "c" "a"
@op_alias "C" "c"

@op_alias "c†" "a†"
@op_alias "Cdag" "c†"
@op_alias "cdag" "c†"

has_fermion_string(::OpName"C", ::SiteType"Fermion") = true
function has_fermion_string(on::OpName"c", st::SiteType"Fermion")
  return has_fermion_string(alias(on), st)
end
has_fermion_string(::OpName"Cdag", ::SiteType"Fermion") = true
function has_fermion_string(on::OpName"c†", st::SiteType"Fermion")
  return has_fermion_string(alias(on), st)
end
function has_fermion_string(on::OpName"cdag", st::SiteType"Fermion")
  return has_fermion_string(alias(on), st)
end
