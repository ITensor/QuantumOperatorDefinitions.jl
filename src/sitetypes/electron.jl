Base.length(::SiteType"Electron") = 4

(::StateName"Emp")(domain::SiteType"Electron") = StateName"0"()(domain)

(::StateName"↑")(::SiteType"Electron") = (StateName"0"() ⊗ StateName"1"())(2, 2)
(::StateName"Up")(domain::SiteType"Electron") = StateName"↑"()(domain)

(::StateName"↓")(domain::SiteType"Electron") = (StateName"1"() ⊗ StateName"0"())(2, 2)
(::StateName"Dn")(domain::SiteType"Electron") = StateName"↓"()(domain)

(::StateName"↑↓")(domain::SiteType"Electron") = (StateName"1"() ⊗ StateName"1"())(2, 2)
(::StateName"UpDn")(domain::SiteType"Electron") = StateName"↑↓"()(domain)

# I ⊗ n
(::OpName"n↑")(::SiteType"Electron") = (OpName"I"() ⊗ OpName"n"())(2, 2)
@op_alias "Nup" "n↑"

# n ⊗ I
(::OpName"n↓")(::SiteType"Electron") = (OpName"n"() ⊗ OpName"I"())(2, 2)
@op_alias "Ndn" "n↓"

# n ⊗ n
(::OpName"n↑↓")(::SiteType"Electron") = (OpName"n"() ⊗ OpName"n"())(2, 2)
@op_alias "Nupdn" "n↑↓"

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
    return cat(falses(1, 1), n.arg(2), falses(1, 1); dims = (1, 2))
end

# These implicitly define other spin operators.
# TODO: Maybe require calling it as `OpName("SpinOp"; arg=OpName("Sz"))`?
function (n::OpName"σ⁺")(domain::SiteType"Electron")
    return OpName"SpinOp"(; arg = n)(domain)
end
function (n::OpName"σᶻ")(domain::SiteType"Electron")
    return OpName"SpinOp"(; arg = n)(domain)
end
function (n::OpName"R")(domain::SiteType"Electron")
    return OpName"SpinOp"(; arg = n)(domain)
end

has_fermion_string(::OpName"c↑", ::SiteType"Electron") = true
has_fermion_string(::OpName"c†↑", ::SiteType"Electron") = true
has_fermion_string(::OpName"c↓", ::SiteType"Electron") = true
has_fermion_string(::OpName"c†↓", ::SiteType"Electron") = true
