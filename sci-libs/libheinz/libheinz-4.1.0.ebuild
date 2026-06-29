# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

MY_P="${PN}-v${PV}"
DESCRIPTION="Header-only C++ vector/rotation primitives used by MLZ scientific software"
HOMEPAGE="https://jugit.fz-juelich.de/mlz/libheinz"
SRC_URI="https://jugit.fz-juelich.de/mlz/libheinz/-/archive/v${PV}/${MY_P}.tar.gz"
S="${WORKDIR}/${MY_P}"

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
