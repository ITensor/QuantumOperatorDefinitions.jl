# TODO: Move to `state.jl`.
function state_alias_expr(name1, name2, pars...)
  return :(
    function alias(n::StateName{Symbol($name1)})
      return StateName{Symbol($name2)}(; params(n)..., $(esc.(pars)...))
    end
  )
end
macro state_alias(name1, name2, params...)
  return state_alias_expr(name1, name2)
end

# TODO: Move to `op.jl`.
function op_alias_expr(name1, name2, pars...)
  return :(
    function alias(n::OpName{Symbol($name1)})
      return OpName{Symbol($name2)}(; params(n)..., $(esc.(pars)...))
    end
  )
end
macro op_alias(name1, name2, pars...)
  return op_alias_expr(name1, name2, pars...)
end

@state_alias "Up" "0"
@state_alias "Dn" "1"
@state_alias "↑" "0"
@state_alias "↓" "1"

# Pauli eingenstates
@state_alias "X+" "+"
@state_alias "Xp" "+"
@state_alias "X-" "+"
@state_alias "Xm" "+"

@state_alias "Y+" "i"
@state_alias "Yp" "i"
@state_alias "Y-" "-i"
@state_alias "Ym" "-i"

@state_alias "Z+" "0"
@state_alias "Zp" "0"
@state_alias "Z-" "1"
@state_alias "Zm" "1"

# SIC-POVMs
@state_alias "Tetra1" "0"

@op_alias "σx" "X"
@op_alias "σ1" "X"
@op_alias "σy" "Y"
@op_alias "σ2" "Y"
@op_alias "iσy" "iY"
@op_alias "iσ2" "iY"
@op_alias "σz" "Z"
@op_alias "σ3" "Z"

@op_alias "T" "π/8"

@op_alias "√X" "√NOT"
@op_alias "PHASE" "Phase"
@op_alias "P" "Phase"

@op_alias "CNOT" "Control" op = OpName"X"()
@op_alias "CX" "Control" op = OpName"X"()
@op_alias "CY" "Control" op = OpName"Y"()
@op_alias "CZ" "Control" op = OpName"Z"()

@op_alias "S" "Phase" ϕ = π / 2

function alias(n::OpName"CPhase")
  return OpName"Control"(; op=OpName"Phase"(; params(n)...))
end
function alias(n::OpName"CRx")
  return OpName"Control"(; ncontrol=1, op=OpName"Rx"(; params(n)...))
end
function Base.AbstractArray(::OpName"CRy")
  return OpName"Control"(; ncontrol=1, op=OpName"Ry"(; params(n)...))
end
function Base.AbstractArray(::OpName"CRz")
  return OpName"Control"(; ncontrol=1, op=OpName"Rz"(; params(n)...))
end
function Base.AbstractArray(::OpName"CRn")
  return OpName"Control"(; ncontrol=1, op=OpName"Rn"(; params(n)...))
end

# TODO: Write in terms of `"Control"`.
@op_alias "CPHASE" "CPhase"
@op_alias "Cphase" "CPhase"
@op_alias "CRX" "CRx"
@op_alias "CRY" "CRy"
@op_alias "CRZ" "CRz"
@op_alias "CRn̂" "CRn"

@op_alias "c" "C"
@op_alias "cdag" "Cdag"
@op_alias "c†" "Cdag"
@op_alias "n" "N"
@op_alias "a" "A"
@op_alias "adag" "Adag"
@op_alias "a↑" "Aup"
@op_alias "a↓" "Adn"
@op_alias "a†↓" "Adagdn"
@op_alias "a†↑" "Adagup"
@op_alias "a†" "Adag"
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
@op_alias "I" "Id"

@op_alias "S²" "S2"
@op_alias "Sᶻ" "Sz"
@op_alias "Sʸ" "Sy"
@op_alias "iSʸ" "iSy"
@op_alias "Sˣ" "Sx"
@op_alias "S⁻" "S-"
@op_alias "Sminus" "S-"
@op_alias "Sm" "S-"
@op_alias "S⁺" "S+"
@op_alias "Splus" "S+"
@op_alias "Sp" "S+"
@op_alias "projUp" "ProjUp"
@op_alias "projDn" "ProjDn"

@op_alias "Proj0" "ProjUp"
@op_alias "Proj1" "ProjDn"
@op_alias "Rn̂" "Rn"
