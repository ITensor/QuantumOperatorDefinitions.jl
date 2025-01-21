# TODO: Move to `state.jl`.
function state_alias_expr(name1, name2, pars...)
  return :(function alias(n::StateName{Symbol($name1)})
    return StateName{Symbol($name2)}(; params(n)..., $(esc.(pars)...))
  end)
end
macro state_alias(name1, name2, params...)
  return state_alias_expr(name1, name2)
end

# TODO: Move to `op.jl`.
function op_alias_expr(name1, name2, pars...)
  return :(function alias(n::OpName{Symbol($name1)})
    return OpName{Symbol($name2)}(; params(n)..., $(esc.(pars)...))
  end)
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

@op_alias "I" "Id"
@op_alias "σ0" "Id"
@op_alias "σ⁰" "Id"
@op_alias "σ₀" "Id"

@op_alias "σx" "X"
@op_alias "σˣ" "X"
@op_alias "σₓ" "X"
@op_alias "σ1" "X"
@op_alias "σ¹" "X"
@op_alias "σ₁" "X"
@op_alias "σy" "Y"
# TODO: No subsript `\_y` available
# in unicode.
@op_alias "σʸ" "Y"
@op_alias "σ2" "Y"
@op_alias "σ²" "Y"
@op_alias "σ₂" "Y"
@op_alias "iσy" "iY"
# TODO: No subsript `\_y` available
# in unicode.
@op_alias "iσʸ" "iY"
@op_alias "iσ2" "iY"
@op_alias "iσ²" "iY"
@op_alias "iσ₂" "iY"
@op_alias "σz" "Z"
# TODO: No subsript `\_z` available
# in unicode.
@op_alias "σᶻ" "Z"
@op_alias "σ3" "Z"
@op_alias "σ³" "Z"
@op_alias "σ₃" "Z"

alias(n::OpName"Sx") = OpName("X") / 2
@op_alias "Sˣ" "Sx"
@op_alias "Sₓ" "Sx"
alias(n::OpName"Sy") = OpName("Y") / 2
@op_alias "Sʸ" "Sy"
alias(n::OpName"iSy") = OpName("iY") / 2
@op_alias "iSʸ" "iSy"
alias(n::OpName"Sz") = OpName("Z") / 2
@op_alias "Sᶻ" "Sz"
@op_alias "S⁻" "S-"
@op_alias "Sminus" "S-"
@op_alias "Sm" "S-"
@op_alias "S⁺" "S+"
@op_alias "Splus" "S+"
@op_alias "Sp" "S+"
alias(n::OpName"S2") = 3 * OpName("I") / 4
@op_alias "S²" "S2"

@op_alias "projUp" "ProjUp"
@op_alias "Proj↑" "ProjUp"
@op_alias "proj↑" "ProjUp"
@op_alias "Proj0" "ProjUp"
@op_alias "proj0" "ProjUp"

@op_alias "projDn" "ProjDn"
@op_alias "Proj↓" "ProjDn"
@op_alias "proj↓" "ProjDn"
@op_alias "Proj1" "ProjDn"
@op_alias "proj1" "ProjDn"

@op_alias "iX" "im" op = OpName"X"()
function alias(::OpName"iY")
  return real(OpName"Y"()im)
end
@op_alias "iZ" "im" op = OpName"Z"()

@op_alias "T" "π/8"

@op_alias "√X" "√" op = OpName"X"()
@op_alias "√NOT" "√" op = OpName"X"()
@op_alias "PHASE" "Phase"
@op_alias "P" "Phase"
@op_alias "Rn̂" "Rn"

@op_alias "CNOT" "Control" op = OpName"X"()
@op_alias "CX" "Control" op = OpName"X"()
@op_alias "CY" "Control" op = OpName"Y"()
@op_alias "CZ" "Control" op = OpName"Z"()

@op_alias "π/8" "Phase" θ = π / 4
@op_alias "S" "Phase" θ = π / 2

function alias(n::OpName"CPhase")
  return controlled(OpName"Phase"(; params(n)...))
end
function alias(n::OpName"CRx")
  return controlled(OpName"Rx"(; params(n)...))
end
function Base.AbstractArray(::OpName"CRy")
  return controlled(OpName"Ry"(; params(n)...))
end
function Base.AbstractArray(::OpName"CRz")
  return controlled(OpName"Rz"(; params(n)...))
end
function Base.AbstractArray(::OpName"CRn")
  return controlled(; op=OpName"Rn"(; params(n)...))
end

# TODO: Write in terms of `"Control"`.
@op_alias "CPHASE" "CPhase"
@op_alias "Cphase" "CPhase"
@op_alias "CRX" "CRx"
@op_alias "CRY" "CRy"
@op_alias "CRZ" "CRz"
@op_alias "CRn̂" "CRn"

@op_alias "SWAP" "OpSWAP" op = OpName"X"()
@op_alias "Swap" "SWAP"
@op_alias "√SWAP" "OpSWAP" op = OpName"√X"()
@op_alias "√Swap" "√SWAP"
@op_alias "iSWAP" "OpSWAP" op = OpName"iX"()
@op_alias "iSwap" "iSWAP"
@op_alias "√iSWAP" "OpSWAP" op = √(OpName"iX"())
@op_alias "√iSwap" "√iSWAP"

@op_alias "RXX" "Rxx"
@op_alias "RYY" "Ryy"
@op_alias "RZZ" "Rzz"

## TODO: This seems to be broken, investigate.
## # Ising (XY) coupling gate
## # exp(-im * θ/2 * X ⊗ Y)
## alias(n::OpName"Rxy") = OpName("OpSWAP"; op=OpName"Rx"(; θ=n.θ))
## @op_alias "RXY" "Rxy"

@op_alias "CCNOT" "Control" ncontrol = 2 op = OpName"X"()
@op_alias "Toffoli" "CCNOT"
@op_alias "CCX" "CCNOT"
@op_alias "TOFF" "CCNOT"

@op_alias "CSWAP" "Control" ncontrol = 2 op = OpName"SWAP"()
@op_alias "Fredkin" "CSWAP"
@op_alias "CSwap" "CSWAP"
@op_alias "CS" "CSWAP"

@op_alias "CCCNOT" "Control" ncontrol = 3 op = OpName"X"()

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
