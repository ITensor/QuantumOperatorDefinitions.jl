Base.length(::SiteType"tJ") = 3

Base.AbstractArray(::StateName"Emp", ::SiteType"tJ") = [1.0, 0, 0]
Base.AbstractArray(::StateName"Up", ::SiteType"tJ") = [0.0, 1, 0]
Base.AbstractArray(::StateName"Dn", ::SiteType"tJ") = [0.0, 0, 1]
Base.AbstractArray(::StateName"0", st::SiteType"tJ") = AbstractArray(StateName("Emp"), st)
Base.AbstractArray(::StateName"↑", st::SiteType"tJ") = AbstractArray(StateName("Up"), st)
Base.AbstractArray(::StateName"↓", st::SiteType"tJ") = AbstractArray(StateName("Dn"), st)

# TODO: Update these to the latest syntax.
## function op!(Op::ITensor, ::OpName"Nup", ::SiteType"tJ", s::Index)
##   return Op[s' => 2, s => 2] = 1.0
## end
## function op!(Op::ITensor, on::OpName"n↑", st::SiteType"tJ", s::Index)
##   return op!(Op, alias(on), st, s)
## end
## 
## function op!(Op::ITensor, ::OpName"Ndn", ::SiteType"tJ", s::Index)
##   return Op[s' => 3, s => 3] = 1.0
## end
## function op!(Op::ITensor, on::OpName"n↓", st::SiteType"tJ", s::Index)
##   return op!(Op, alias(on), st, s)
## end
## 
## function op!(Op::ITensor, ::OpName"Ntot", ::SiteType"tJ", s::Index)
##   Op[s' => 2, s => 2] = 1.0
##   return Op[s' => 3, s => 3] = 1.0
## end
## function op!(Op::ITensor, on::OpName"ntot", st::SiteType"tJ", s::Index)
##   return op!(Op, alias(on), st, s)
## end
## 
## function op!(Op::ITensor, ::OpName"Cup", ::SiteType"tJ", s::Index)
##   return Op[s' => 1, s => 2] = 1.0
## end
## function op!(Op::ITensor, on::OpName"c↑", st::SiteType"tJ", s::Index)
##   return op!(Op, alias(on), st, s)
## end
## 
## function op!(Op::ITensor, ::OpName"Cdagup", ::SiteType"tJ", s::Index)
##   return Op[s' => 2, s => 1] = 1.0
## end
## function op!(Op::ITensor, on::OpName"c†↑", st::SiteType"tJ", s::Index)
##   return op!(Op, alias(on), st, s)
## end
## 
## function op!(Op::ITensor, ::OpName"Cdn", ::SiteType"tJ", s::Index)
##   return Op[s' => 1, s => 3] = 1.0
## end
## function op!(Op::ITensor, on::OpName"c↓", st::SiteType"tJ", s::Index)
##   return op!(Op, alias(on), st, s)
## end
## 
## function op!(Op::ITensor, ::OpName"Cdagdn", ::SiteType"tJ", s::Index)
##   return Op[s' => 3, s => 1] = 1.0
## end
## function op!(Op::ITensor, on::OpName"c†↓", st::SiteType"tJ", s::Index)
##   return op!(Op, alias(on), st, s)
## end
## 
## function op!(Op::ITensor, ::OpName"Aup", ::SiteType"tJ", s::Index)
##   return Op[s' => 1, s => 2] = 1.0
## end
## function op!(Op::ITensor, on::OpName"a↑", st::SiteType"tJ", s::Index)
##   return op!(Op, alias(on), st, s)
## end
## 
## function op!(Op::ITensor, ::OpName"Adagup", ::SiteType"tJ", s::Index)
##   return Op[s' => 2, s => 1] = 1.0
## end
## function op!(Op::ITensor, on::OpName"a†↑", st::SiteType"tJ", s::Index)
##   return op!(Op, alias(on), st, s)
## end
## 
## function op!(Op::ITensor, ::OpName"Adn", ::SiteType"tJ", s::Index)
##   return Op[s' => 1, s => 3] = 1.0
## end
## function op!(Op::ITensor, on::OpName"a↓", st::SiteType"tJ", s::Index)
##   return op!(Op, alias(on), st, s)
## end
## 
## function op!(Op::ITensor, ::OpName"Adagdn", ::SiteType"tJ", s::Index)
##   return Op[s' => 3, s => 1] = 1.0
## end
## function op!(Op::ITensor, on::OpName"a†↓", st::SiteType"tJ", s::Index)
##   return op!(Op, alias(on), st, s)
## end
## 
## function op!(Op::ITensor, ::OpName"F", ::SiteType"tJ", s::Index)
##   Op[s' => 1, s => 1] = +1.0
##   Op[s' => 2, s => 2] = -1.0
##   return Op[s' => 3, s => 3] = -1.0
## end
## 
## function op!(Op::ITensor, ::OpName"Fup", ::SiteType"tJ", s::Index)
##   Op[s' => 1, s => 1] = +1.0
##   Op[s' => 2, s => 2] = -1.0
##   return Op[s' => 3, s => 3] = +1.0
## end
## function op!(Op::ITensor, on::OpName"F↑", st::SiteType"tJ", s::Index)
##   return op!(Op, alias(on), st, s)
## end
## 
## function op!(Op::ITensor, ::OpName"Fdn", ::SiteType"tJ", s::Index)
##   Op[s' => 1, s => 1] = +1.0
##   Op[s' => 2, s => 2] = +1.0
##   return Op[s' => 3, s => 3] = -1.0
## end
## function op!(Op::ITensor, on::OpName"F↓", st::SiteType"tJ", s::Index)
##   return op!(Op, alias(on), st, s)
## end
## 
## function op!(Op::ITensor, ::OpName"Sz", ::SiteType"tJ", s::Index)
##   Op[s' => 2, s => 2] = +0.5
##   return Op[s' => 3, s => 3] = -0.5
## end
## 
## function op!(Op::ITensor, ::OpName"Sᶻ", st::SiteType"tJ", s::Index)
##   return op!(Op, OpName("Sz"), st, s)
## end
## 
## function op!(Op::ITensor, ::OpName"Sx", ::SiteType"tJ", s::Index)
##   Op[s' => 2, s => 3] = 0.5
##   return Op[s' => 3, s => 2] = 0.5
## end
## 
## function op!(Op::ITensor, ::OpName"Sˣ", st::SiteType"tJ", s::Index)
##   return op!(Op, OpName("Sx"), st, s)
## end
## 
## function op!(Op::ITensor, ::OpName"S+", ::SiteType"tJ", s::Index)
##   return Op[s' => 2, s => 3] = 1.0
## end
## 
## function op!(Op::ITensor, ::OpName"S⁺", st::SiteType"tJ", s::Index)
##   return op!(Op, OpName("S+"), st, s)
## end
## function op!(Op::ITensor, ::OpName"Sp", st::SiteType"tJ", s::Index)
##   return op!(Op, OpName("S+"), st, s)
## end
## function op!(Op::ITensor, ::OpName"Splus", st::SiteType"tJ", s::Index)
##   return op!(Op, OpName("S+"), st, s)
## end
## 
## function op!(Op::ITensor, ::OpName"S-", ::SiteType"tJ", s::Index)
##   return Op[s' => 3, s => 2] = 1.0
## end
## 
## function op!(Op::ITensor, ::OpName"S⁻", st::SiteType"tJ", s::Index)
##   return op!(Op, OpName("S-"), st, s)
## end
## function op!(Op::ITensor, ::OpName"Sm", st::SiteType"tJ", s::Index)
##   return op!(Op, OpName("S-"), st, s)
## end
## function op!(Op::ITensor, ::OpName"Sminus", st::SiteType"tJ", s::Index)
##   return op!(Op, OpName("S-"), st, s)
## end

has_fermion_string(::OpName"Cup", ::SiteType"tJ") = true
function has_fermion_string(on::OpName"c↑", st::SiteType"tJ")
  return has_fermion_string(alias(on), st)
end
has_fermion_string(::OpName"Cdagup", ::SiteType"tJ") = true
function has_fermion_string(on::OpName"c†↑", st::SiteType"tJ")
  return has_fermion_string(alias(on), st)
end
has_fermion_string(::OpName"Cdn", ::SiteType"tJ") = true
function has_fermion_string(on::OpName"c↓", st::SiteType"tJ")
  return has_fermion_string(alias(on), st)
end
has_fermion_string(::OpName"Cdagdn", ::SiteType"tJ") = true
function has_fermion_string(on::OpName"c†↓", st::SiteType"tJ")
  return has_fermion_string(alias(on), st)
end
