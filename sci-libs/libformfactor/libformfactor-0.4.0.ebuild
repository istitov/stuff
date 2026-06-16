# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

MY_P="${PN}-v${PV}"
DESCRIPTION="Computes Fourier shape transforms (form factors) for BornAgain"
HOMEPAGE="https://jugit.fz-juelich.de/mlz/libformfactor"
SRC_URI="https://jugit.fz-juelich.de/mlz/libformfactor/-/archive/v${PV}/${MY_P}.tar.gz"
S="${WORKDIR}/${MY_P}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# find_package(LibHeinz REQUIRED) carries no version, but 0.4.0 is the
# libheinz-4.0 co-release (paired with bornagain-24.0) and 2.0.1 is still in
# tree; floor at 4.0 so the build can't resolve against the old major.
DEPEND=">=sci-libs/libheinz-4.0"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs=(
		-DPEDANTIC=OFF
		-DWERROR=OFF
	)
	cmake_src_configure
}
