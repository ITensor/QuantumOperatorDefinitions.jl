Base.length(t::SiteType"Qudit") = t.length
alias(::SiteType"Boson") = SiteType"Qudit"()
