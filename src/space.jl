space(st::SiteType; kwargs...) = nothing

space(st::SiteType, n::Int; kwargs...) = space(st; kwargs...)

function space_error_message(st::SiteType)
  return "Overload of \"space\",\"siteind\", or \"siteinds\" functions not found for Index tag: $(value(st))"
end
