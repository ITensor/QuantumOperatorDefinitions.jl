module QuantumOperatorDefinitions

export @OpName_str, @SiteType_str, @StateName_str, OpName, SiteType, StateName, ⊗, op, state

include("sitetype.jl")
include("state.jl")
include("op.jl")
include("has_fermion_string.jl")
include("sitetypes/qubit.jl")
include("sitetypes/spinone.jl")
include("sitetypes/fermion.jl")
include("sitetypes/electron.jl")
include("sitetypes/tj.jl")
include("sitetypes/qudit.jl")

end
