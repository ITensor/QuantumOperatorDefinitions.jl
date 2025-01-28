Base.length(t::SiteType"Qudit") = t.dim
alias(t::SiteType"Boson") = SiteType"Qudit"(; dim=t.dim)
alias(t::SiteType"S") = SiteType"Qudit"(; dim=Int(2t.spin + 1))
