# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

MY_P="${PN}-v${PV}"
DESCRIPTION="Header-only C++ vector/rotation primitives used by MLZ scientific software"
HOMEPAGE="https://jugit.fz-juelich.de/mlz/lib/heinz"
# jugit moved mlz/libheinz into the mlz/lib/ subgroup, regenerating the tag
# archive: it now unpacks to heinz-v<ver>-<full-sha> (subgroup project name +
# commit), so pin the tag commit for S=. verified 2026-08-10
COMMIT="0a6d286d9fb69cffaa5ebd084c594a36cc7a38e0"
SRC_URI="https://jugit.fz-juelich.de/mlz/lib/heinz/-/archive/v${PV}/${MY_P}.tar.gz"
S="${WORKDIR}/heinz-v${PV}-${COMMIT}"

LICENSE="0BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

src_configure() {
	local mycmakeargs=(
		-DPEDANTIC=OFF
		-DWERROR=OFF
	)
	cmake_src_configure
}
