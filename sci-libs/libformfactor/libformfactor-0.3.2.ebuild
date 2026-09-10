# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

MY_P="${PN}-v${PV}"
DESCRIPTION="Computes Fourier shape transforms (form factors) for BornAgain"
HOMEPAGE="https://jugit.fz-juelich.de/mlz/lib/formfactor"
SRC_URI="https://jugit.fz-juelich.de/mlz/lib/formfactor/-/archive/v${PV}/${MY_P}.tar.gz"
# The tag archive's root includes its full commit; pin it for S.
# verified 2026-08-10
COMMIT="7e235d29b1ab60f2e4788e7c819d7c0277aa2954"
S="${WORKDIR}/formfactor-v${PV}-${COMMIT}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# This release uses the libheinz 2 API; exclude the 4.0 co-release stack.
DEPEND=">=sci-libs/libheinz-2.0.0 <sci-libs/libheinz-3"
RDEPEND="${DEPEND}"

src_prepare() {
	# Replace upstream's hardcoded lib directory with the multilib path.
	sed -i -e 's|DESTINATION lib$|DESTINATION ${CMAKE_INSTALL_LIBDIR}|' \
		-e 's|DESTINATION lib)|DESTINATION ${CMAKE_INSTALL_LIBDIR})|' \
		ff/CMakeLists.txt || die

	# Install package files where find_package searches by default.
	sed -i 's|DESTINATION cmake)|DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/formfactor)|g' \
		CMakeLists.txt || die

	# Keep PACKAGE_PREFIX_DIR relative to the corrected config location.
	sed -i 's|INSTALL_DESTINATION cmake|INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/formfactor|' \
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
