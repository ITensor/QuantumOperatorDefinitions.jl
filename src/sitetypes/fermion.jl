Base.length(::SiteType"Fermion") = 2

# TODO: Update these, using aliasing to minimize definitions.
Base.AbstractArray(::StateName"Emp", ::SiteType"Fermion") = [1.0 0.0]
Base.AbstractArray(::StateName"Occ", ::SiteType"Fermion") = [0.0 1.0]
function Base.AbstractArray(::StateName"0", st::SiteType"Fermion")
  return AbstractArray(StateName("Emp"), st)
end
function Base.AbstractArray(::StateName"1", st::SiteType"Fermion")
  return AbstractArray(StateName("Occ"), st)
end

(::OpName"F")(::SiteType"Fermion") = Diagonal([1, -1])

@op_alias "c" "a"
@op_alias "C" "c"

@op_alias "c†" "a†"
@op_alias "Cdag" "c†"
@op_alias "cdag" "c†"

has_fermion_string(::OpName"c", ::SiteType"Fermion") = true
has_fermion_string(::OpName"c†", ::SiteType"Fermion") = true
