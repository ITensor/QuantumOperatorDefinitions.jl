Base.length(::SiteType"Electron") = 4

# TODO: Write these in terms of Kronecker products of Qubit states.
Base.AbstractArray(::StateName"Emp", ::Tuple{SiteType"Electron"}) = [1.0, 0, 0, 0]
Base.AbstractArray(::StateName"Up", ::Tuple{SiteType"Electron"}) = [0.0, 1, 0, 0]
Base.AbstractArray(::StateName"Dn", ::Tuple{SiteType"Electron"}) = [0.0, 0, 1, 0]
Base.AbstractArray(::StateName"UpDn", ::Tuple{SiteType"Electron"}) = [0.0, 0, 0, 1]
# TODO: Use aliasing.
function Base.AbstractArray(::StateName"0", st::Tuple{SiteType"Electron"})
  return AbstractArray(StateName("Emp"), st)
end
function Base.AbstractArray(::StateName"↑", st::Tuple{SiteType"Electron"})
  return AbstractArray(StateName("Up"), st)
end
function Base.AbstractArray(::StateName"↓", st::Tuple{SiteType"Electron"})
  return AbstractArray(StateName("Dn"), st)
end
function Base.AbstractArray(::StateName"↑↓", st::Tuple{SiteType"Electron"})
  return AbstractArray(StateName("UpDn"), st)
end

# I ⊗ n
(::OpName"Nup")(::SiteType"Electron") = (OpName"I"() ⊗ OpName"n"())(2, 2)
@op_alias "n↑" "Nup"

# n ⊗ I
(::OpName"Ndn")(::SiteType"Electron") = (OpName"n"() ⊗ OpName"I"())(2, 2)
@op_alias "n↓" "Ndn"

# n ⊗ n
(::OpName"Nupdn")(::SiteType"Electron") = (OpName"n"() ⊗ OpName"n"())(2, 2)
@op_alias "n↑↓" "Nupdn"

# I ⊗ n + n ⊗ I = n↑ + n↓
alias(::OpName"ntot") = OpName"n↑"() + OpName"n↓"()
@op_alias "Ntot" "ntot"

# I ⊗ a
(::OpName"a↑")(::SiteType"Electron") = (OpName"I"() ⊗ OpName"a"())(2, 2)
@op_alias "Aup" "a↑"
# I ⊗ c
@op_alias "c↑" "a↑"
@op_alias "Cup" "c↑"

# I ⊗ a†
(::OpName"a†↑")(::SiteType"Electron") = (OpName"I"() ⊗ OpName"a†"())(2, 2)
@op_alias "Adagup" "a†↑"
# I ⊗ c†
@op_alias "c†↑" "a†↑"
@op_alias "Cdagup" "c†↑"

# a ⊗ I
(::OpName"a↓")(::SiteType"Electron") = (OpName"a"() ⊗ OpName"I"())(2, 2)
@op_alias "Adn" "a↓"
# c ⊗ F
function (::OpName"c↓")(::SiteType"Electron")
  return (OpName"C"() ⊗ OpName"F"())(SiteType"Fermion"(), SiteType"Fermion"())
end
@op_alias "Cdn" "c↓"

# a† ⊗ I
(::OpName"a†↓")(::SiteType"Electron") = (OpName"a†"() ⊗ OpName"I"())(2, 2)
@op_alias "Adagdn" "a†↓"
# c† ⊗ F
function (::OpName"c†↓")(::SiteType"Electron")
  return (OpName"Cdag"() ⊗ OpName"F"())(SiteType"Fermion"(), SiteType"Fermion"())
end
@op_alias "Cdagdn" "c†↓"

# F ⊗ F
function (::OpName"F")(::SiteType"Electron")
  return (OpName"F"() ⊗ OpName"F"())(SiteType"Fermion"(), SiteType"Fermion"())
end

# I ⊗ F
function (::OpName"F↑")(::SiteType"Electron")
  return (OpName"I"() ⊗ OpName"F"())(SiteType"Fermion"(), SiteType"Fermion"())
end
@op_alias "Fup" "F↑"

# F ⊗ I
function (::OpName"F↓")(::SiteType"Electron")
  return (OpName"F"() ⊗ OpName"I"())(SiteType"Fermion"(), SiteType"Fermion"())
end
@op_alias "Fdn" "F↓"

function (n::OpName"SpinOp")(::SiteType"Electron")
  return cat(falses(1, 1), n.op(2), falses(1, 1); dims=(1, 2))
end

# These implicitly define other spin operators.
# TODO: Maybe require calling it as `OpName("SpinOp"; op=OpName("Sz"))`?
function (n::OpName"σ⁺")(domain::SiteType"Electron")
  return OpName"SpinOp"(; op=n)(domain)
end
function (n::OpName"σᶻ")(domain::SiteType"Electron")
  return OpName"SpinOp"(; op=n)(domain)
end
function (n::OpName"R")(domain::SiteType"Electron")
  return OpName"SpinOp"(; op=n)(domain)
end

has_fermion_string(::OpName"c↑", ::SiteType"Electron") = true
has_fermion_string(::OpName"c†↑", ::SiteType"Electron") = true
has_fermion_string(::OpName"c↓", ::Tuple{SiteType"Electron"}) = true
has_fermion_string(::OpName"c†↓", ::SiteType"Electron") = true
