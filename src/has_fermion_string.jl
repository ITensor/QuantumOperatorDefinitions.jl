function has_fermion_string(n::OpName, t::SiteType)
  n′ = alias(n)
  if n == n′
    return false
  end
  return has_fermion_string(n′, t)
end
