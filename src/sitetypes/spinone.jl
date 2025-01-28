Base.length(::SiteType"S=1") = 3

alias(::SiteType"SpinOne") = SiteType"S=1"()

# TODO: Make these more general, define as something like:
# `(n::StateName"Z")(::SiteType"S=1") = eigvecs(OpName"Z"())[n.eigval]`
(::StateName"Z+")(::SiteType"S=1") = [1, 0, 0]
(::StateName"Z0")(::SiteType"S=1") = [0, 1, 0]
(::StateName"Z-")(::SiteType"S=1") = [0, 0, 1]

## TODO: Decide on these aliases.
(::StateName"↑")(::SiteType"S=1") = StateName"Z+"()(domain)
(::StateName"Up")(::SiteType"S=1") = StateName"Z+"()(domain)
(::StateName"0")(::SiteType"S=1") = StateName"Z0"()(domain)
(::StateName"↓")(::SiteType"S=1") = StateName"Z-"()(domain)
(::StateName"Dn")(::SiteType"S=1") = StateName"Z-"()(domain)

# TODO: Make these more general, define as something like:
# `(n::StateName"X")(::SiteType"S=1") = eigvecs(OpName"X"())[n.eigval]`
(::StateName"X+")(::SiteType"S=1") = [1 / 2, 1 / sqrt(2), 1 / 2]
(::StateName"X0")(::SiteType"S=1") = [-1 / sqrt(2), 0, 1 / sqrt(2)]
(::StateName"X-")(::SiteType"S=1") = [1 / 2, -1 / sqrt(2), 1 / 2]

# TODO: Make these more general, define as something like:
# `(n::StateName"Y")(::SiteType"S=1") = eigvecs(OpName"Y"())[n.eigval]`
(::StateName"Y+")(::SiteType"S=1") = [-1 / 2, -im / sqrt(2), 1 / 2]
(::StateName"Y0")(::SiteType"S=1") = [1 / sqrt(2), 0, 1 / sqrt(2)]
(::StateName"Y-")(::SiteType"S=1") = [-1 / 2, im / sqrt(2), 1 / 2]
