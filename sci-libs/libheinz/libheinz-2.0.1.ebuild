# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

MY_P="${PN}-v${PV}"
DESCRIPTION="Header-only C++ vector/rotation primitives used by MLZ scientific software"
HOMEPAGE="https://jugit.fz-juelich.de/mlz/lib/heinz"
# The tag archive's root includes its full commit; pin it for S.
# verified 2026-08-10
COMMIT="92c1aea016a17f9657d2bb54fe38f301891b6be5"
SRC_URI="https://jugit.fz-juelich.de/mlz/lib/heinz/-/archive/v${PV}/${MY_P}.tar.gz"
S="${WORKDIR}/heinz-v${PV}-${COMMIT}"

LICENSE="0BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

src_prepare() {
	# Install package files where find_package searches by default.
	sed -i 's|DESTINATION cmake |DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/LibHeinz |' \
		CMakeLists.txt || die

	# Keep generated relative paths aligned with the corrected destination.
	sed -i 's|INSTALL_DESTINATION "lib/cmake/example"|INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/LibHeinz"|' \
		CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DPEDANTIC=OFF
		-DWERROR=OFF
	)
	cmake_src_configure
}
