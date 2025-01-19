module ITensorQuantumOperatorDefinitionsChainRulesCoreExt

using ChainRulesCore: @non_differentiable
using ..ITensorQuantumOperatorDefinitions: SiteType, _sitetypes, has_fermion_string

@non_differentiable has_fermion_string(::AbstractString, ::Any)
@non_differentiable SiteType(::Any)
@non_differentiable _sitetypes(::Any)

end
