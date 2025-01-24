Base.length(::SiteType"S=1") = 3

alias(::SiteType"SpinOne") = SiteType"S=1"()

# TODO: Decide on these names, use `alias`.
# TODO: Make a more general `SiteType"Spin`/`SiteType"S"`
# with a `spin` field that can be set to a rational number
# `1//2, `2//2`, `3//2`, etc. that maps to `Qudit`
# of length `2 * spin + 1`.
Base.AbstractArray(::StateName"Up", ::SiteType"S=1") = [1, 0, 0]
Base.AbstractArray(::StateName"Z0", ::SiteType"S=1") = [0, 1, 0]
Base.AbstractArray(::StateName"Dn", ::SiteType"S=1") = [0, 0, 1]

Base.AbstractArray(::StateName"↑", st::SiteType"S=1") = [1, 0, 0]
Base.AbstractArray(::StateName"0", st::SiteType"S=1") = [0, 1, 0]
Base.AbstractArray(::StateName"↓", st::SiteType"S=1") = [0, 0, 1]

Base.AbstractArray(::StateName"Z+", st::SiteType"S=1") = [1.0, 0.0, 0.0]
# -- Z0 is already defined above --
Base.AbstractArray(::StateName"Z-", st::SiteType"S=1") = [0.0, 0.0, 1.0]

Base.AbstractArray(::StateName"X+", ::SiteType"S=1") = [1 / 2, 1 / sqrt(2), 1 / 2]
Base.AbstractArray(::StateName"X0", ::SiteType"S=1") = [-1 / sqrt(2), 0, 1 / sqrt(2)]
Base.AbstractArray(::StateName"X-", ::SiteType"S=1") = [1 / 2, -1 / sqrt(2), 1 / 2]

Base.AbstractArray(::StateName"Y+", ::SiteType"S=1") = [-1 / 2, -im / sqrt(2), 1 / 2]
Base.AbstractArray(::StateName"Y0", ::SiteType"S=1") = [1 / sqrt(2), 0, 1 / sqrt(2)]
Base.AbstractArray(::StateName"Y-", ::SiteType"S=1") = [-1 / 2, im / sqrt(2), 1 / 2]
