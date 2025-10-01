Base.length(::SiteType"tJ") = 3

function (n::StateName)(domain::SiteType"tJ")
    return n(SiteType"Electron"())[1:length(domain)]
end

function (n::OpName)(domain::SiteType"tJ")
    return n(SiteType"Electron"())[1:length(domain), 1:length(domain)]
end

has_fermion_string(::OpName"c↑", ::SiteType"tJ") = true
has_fermion_string(::OpName"c†↑", ::SiteType"tJ") = true
has_fermion_string(::OpName"c↓", ::SiteType"tJ") = true
has_fermion_string(::OpName"c†↓", ::SiteType"tJ") = true
