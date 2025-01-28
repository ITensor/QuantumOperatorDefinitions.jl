# TODO: Make an alias of `"Qubit"` to inherit
# more operator and state definitions?

Base.length(::SiteType"Fermion") = 2

(::OpName"F")(::SiteType"Fermion") = Diagonal([1, -1])

@op_alias "c" "a"
@op_alias "C" "c"

@op_alias "c†" "a†"
@op_alias "Cdag" "c†"
@op_alias "cdag" "c†"

has_fermion_string(::OpName"c", ::SiteType"Fermion") = true
has_fermion_string(::OpName"c†", ::SiteType"Fermion") = true
