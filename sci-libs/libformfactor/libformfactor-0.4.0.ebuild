# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

MY_P="${PN}-v${PV}"
DESCRIPTION="Computes Fourier shape transforms (form factors) for BornAgain"
HOMEPAGE="https://jugit.fz-juelich.de/mlz/lib/formfactor"
SRC_URI="https://jugit.fz-juelich.de/mlz/lib/formfactor/-/archive/v${PV}/${MY_P}.tar.gz"
# jugit's tag archive unpacks to formfactor-v<ver>-<full-sha> (mlz/libformfactor
# moved to mlz/lib/formfactor upstream), so pin the tag commit for S=.
# verified 2026-08-10
COMMIT="645c2d7dae8df775a9d253c0258356f8e39621f3"
S="${WORKDIR}/formfactor-v${PV}-${COMMIT}"

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
