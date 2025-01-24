Base.length(::SiteType"Electron") = 4

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
# TODO: Define as `AbstractArray(OpName"I"() ⊗ OpName"n"(), (SiteType("Fermion"), SiteType("Fermion")))`?
function Base.AbstractArray(::OpName"Nup", ::Tuple{SiteType"Electron"})
  return [
    0.0 0.0 0.0 0.0
    0.0 1.0 0.0 0.0
    0.0 0.0 0.0 0.0
    0.0 0.0 0.0 1.0
  ]
end
function Base.AbstractArray(on::OpName"n↑", st::Tuple{SiteType"Electron"})
  return AbstractArray(alias(on), st)
end

# n ⊗ I
function Base.AbstractArray(::OpName"Ndn", ::Tuple{SiteType"Electron"})
  return [
    0.0 0.0 0.0 0.0
    0.0 0.0 0.0 0.0
    0.0 0.0 1.0 0.0
    0.0 0.0 0.0 1.0
  ]
end
function Base.AbstractArray(on::OpName"n↓", st::Tuple{SiteType"Electron"})
  return AbstractArray(alias(on), st)
end

# n ⊗ n
function Base.AbstractArray(::OpName"Nupdn", ::Tuple{SiteType"Electron"})
  return [
    0.0 0.0 0.0 0.0
    0.0 0.0 0.0 0.0
    0.0 0.0 0.0 0.0
    0.0 0.0 0.0 1.0
  ]
end
function Base.AbstractArray(on::OpName"n↑↓", st::Tuple{SiteType"Electron"})
  return AbstractArray(alias(on), st)
end

# I ⊗ n + n ⊗ I
function Base.AbstractArray(::OpName"Ntot", ::Tuple{SiteType"Electron"})
  return [
    0.0 0.0 0.0 0.0
    0.0 1.0 0.0 0.0
    0.0 0.0 1.0 0.0
    0.0 0.0 0.0 2.0
  ]
end
function Base.AbstractArray(on::OpName"ntot", st::Tuple{SiteType"Electron"})
  return AbstractArray(alias(on), st)
end

# I ⊗ c
function Base.AbstractArray(::OpName"Cup", ::Tuple{SiteType"Electron"})
  return [
    0.0 1.0 0.0 0.0
    0.0 0.0 0.0 0.0
    0.0 0.0 0.0 1.0
    0.0 0.0 0.0 0.0
  ]
end
function Base.AbstractArray(on::OpName"c↑", st::Tuple{SiteType"Electron"})
  return AbstractArray(alias(on), st)
end

# I ⊗ c†
function Base.AbstractArray(::OpName"Cdagup", ::Tuple{SiteType"Electron"})
  return [
    0.0 0.0 0.0 0.0
    1.0 0.0 0.0 0.0
    0.0 0.0 0.0 0.0
    0.0 0.0 1.0 0.0
  ]
end
function Base.AbstractArray(on::OpName"c†↑", st::Tuple{SiteType"Electron"})
  return AbstractArray(alias(on), st)
end

# c ⊗ F
function Base.AbstractArray(::OpName"Cdn", ::Tuple{SiteType"Electron"})
  return [
    0.0 0.0 1.0 0.0
    0.0 0.0 0.0 -1.0
    0.0 0.0 0.0 0.0
    0.0 0.0 0.0 0.0
  ]
end
function Base.AbstractArray(on::OpName"c↓", st::Tuple{SiteType"Electron"})
  return AbstractArray(alias(on), st)
end

# c† ⊗ F
function Base.AbstractArray(::OpName"Cdagdn", ::Tuple{SiteType"Electron"})
  return [
    0.0 0.0 0.0 0.0
    0.0 0.0 0.0 0.0
    1.0 0.0 0.0 0.0
    0.0 -1.0 0.0 0.0
  ]
end
function Base.AbstractArray(::OpName"c†↓", st::Tuple{SiteType"Electron"})
  return AbstractArray(OpName("Cdagdn"), st)
end

# I ⊗ a
function Base.AbstractArray(::OpName"Aup", ::Tuple{SiteType"Electron"})
  return [
    0.0 1.0 0.0 0.0
    0.0 0.0 0.0 0.0
    0.0 0.0 0.0 1.0
    0.0 0.0 0.0 0.0
  ]
end
function Base.AbstractArray(::OpName"a↑", st::Tuple{SiteType"Electron"})
  return AbstractArray(OpName("Aup"), st)
end

# I ⊗ a†
function Base.AbstractArray(::OpName"Adagup", ::Tuple{SiteType"Electron"})
  return [
    0.0 0.0 0.0 0.0
    1.0 0.0 0.0 0.0
    0.0 0.0 0.0 0.0
    0.0 0.0 1.0 0.0
  ]
end
function Base.AbstractArray(::OpName"a†↑", st::Tuple{SiteType"Electron"})
  return AbstractArray(OpName("Adagup"), st)
end

# a ⊗ I
function Base.AbstractArray(::OpName"Adn", ::Tuple{SiteType"Electron"})
  return [
    0.0 0.0 1.0 0.0
    0.0 0.0 0.0 1.0
    0.0 0.0 0.0 0.0
    0.0 0.0 0.0 0.0
  ]
end
function Base.AbstractArray(::OpName"a↓", st::Tuple{SiteType"Electron"})
  return AbstractArray(OpName("Adn"), st)
end

# a† ⊗ I
function Base.AbstractArray(::OpName"Adagdn", ::Tuple{SiteType"Electron"})
  return [
    0.0 0.0 0.0 0.0
    0.0 0.0 0.0 0.0
    1.0 0.0 0.0 0.0
    0.0 1.0 0.0 0.0
  ]
end
function Base.AbstractArray(::OpName"a†↓", st::Tuple{SiteType"Electron"})
  return AbstractArray(OpName("Adagdn"), st)
end

# F ⊗ F
function Base.AbstractArray(::OpName"F", ::Tuple{SiteType"Electron"})
  return [
    1.0 0.0 0.0 0.0
    0.0 -1.0 0.0 0.0
    0.0 0.0 -1.0 0.0
    0.0 0.0 0.0 1.0
  ]
end

# I ⊗ F
function Base.AbstractArray(::OpName"Fup", ::Tuple{SiteType"Electron"})
  return [
    1.0 0.0 0.0 0.0
    0.0 -1.0 0.0 0.0
    0.0 0.0 1.0 0.0
    0.0 0.0 0.0 -1.0
  ]
end
function Base.AbstractArray(::OpName"F↑", st::Tuple{SiteType"Electron"})
  return AbstractArray(OpName("Fup"), st)
end

# F ⊗ I
function Base.AbstractArray(::OpName"Fdn", ::Tuple{SiteType"Electron"})
  return [
    1.0 0.0 0.0 0.0
    0.0 1.0 0.0 0.0
    0.0 0.0 -1.0 0.0
    0.0 0.0 0.0 -1.0
  ]
end
function Base.AbstractArray(::OpName"F↓", st::Tuple{SiteType"Electron"})
  return AbstractArray(OpName("Fdn"), st)
end

function Base.AbstractArray(::OpName"Sz", ::Tuple{SiteType"Electron"})
  # cat(falses(1, 1), Matrix(OpName("Sz")), falses(1, 1); dims=(1, 2))
  return [
    0.0 0.0 0.0 0.0
    0.0 0.5 0.0 0.0
    0.0 0.0 -0.5 0.0
    0.0 0.0 0.0 0.0
  ]
end
function Base.AbstractArray(::OpName"Sᶻ", st::Tuple{SiteType"Electron"})
  return AbstractArray(OpName("Sz"), st)
end

function Base.AbstractArray(::OpName"Sx", ::Tuple{SiteType"Electron"})
  # cat(falses(1, 1), Matrix(OpName("Sx")), falses(1, 1); dims=(1, 2))
  return [
    0.0 0.0 0.0 0.0
    0.0 0.0 0.5 0.0
    0.0 0.5 0.0 0.0
    0.0 0.0 0.0 0.0
  ]
end

function Base.AbstractArray(::OpName"Sˣ", st::Tuple{SiteType"Electron"})
  return AbstractArray(OpName("Sx"), st)
end

function Base.AbstractArray(::OpName"S⁺", ::Tuple{SiteType"Electron"})
  # cat(falses(1, 1), Matrix(OpName("S⁺")), falses(1, 1); dims=(1, 2))
  return [
    0.0 0.0 0.0 0.0
    0.0 0.0 1.0 0.0
    0.0 0.0 0.0 0.0
    0.0 0.0 0.0 0.0
  ]
end
function Base.AbstractArray(::OpName"Sp", st::Tuple{SiteType"Electron"})
  return AbstractArray(OpName("S⁺"), st)
end
function Base.AbstractArray(::OpName"Splus", st::Tuple{SiteType"Electron"})
  return AbstractArray(OpName("S⁺"), st)
end

function Base.AbstractArray(::OpName"S⁻", ::Tuple{SiteType"Electron"})
  # cat(falses(1, 1), Matrix(OpName("S⁻")), falses(1, 1); dims=(1, 2))
  return [
    0.0 0.0 0.0 0.0
    0.0 0.0 0.0 0.0
    0.0 1.0 0.0 0.0
    0.0 0.0 0.0 0.0
  ]
end
function Base.AbstractArray(::OpName"Sm", st::Tuple{SiteType"Electron"})
  return AbstractArray(OpName("S⁻"), st)
end
function Base.AbstractArray(::OpName"Sminus", st::Tuple{SiteType"Electron"})
  return AbstractArray(OpName("S⁻"), st)
end

@op_alias "a↑" "Aup"
@op_alias "a↓" "Adn"
@op_alias "a†↓" "Adagdn"
@op_alias "a†↑" "Adagup"
@op_alias "c↑" "Cup"
@op_alias "c↓" "Cdn"
@op_alias "c†↑" "Cdagup"
@op_alias "c†↓" "Cdagdn"
@op_alias "n↑" "Nup"
@op_alias "n↓" "Ndn"
@op_alias "n↑↓" "Nupdn"
@op_alias "ntot" "Ntot"
@op_alias "F↑" "Fup"
@op_alias "F↓" "Fdn"

has_fermion_string(::OpName"Cup", ::Tuple{SiteType"Electron"}) = true
function has_fermion_string(on::OpName"c↑", st::Tuple{SiteType"Electron"})
  return has_fermion_string(alias(on), st)
end
has_fermion_string(::OpName"Cdagup", ::Tuple{SiteType"Electron"}) = true
function has_fermion_string(on::OpName"c†↑", st::Tuple{SiteType"Electron"})
  return has_fermion_string(alias(on), st)
end
has_fermion_string(::OpName"Cdn", ::Tuple{SiteType"Electron"}) = true
function has_fermion_string(on::OpName"c↓", st::Tuple{SiteType"Electron"})
  return has_fermion_string(alias(on), st)
end
has_fermion_string(::OpName"Cdagdn", ::Tuple{SiteType"Electron"}) = true
function has_fermion_string(on::OpName"c†↓", st::Tuple{SiteType"Electron"})
  return has_fermion_string(alias(on), st)
end
