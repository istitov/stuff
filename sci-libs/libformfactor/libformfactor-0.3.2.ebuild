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

# Built against the libheinz 2.x API; cap below 3 so the libheinz-4.0
# co-release of libformfactor-0.4.0 / bornagain-24.0 can't be pulled in here.
DEPEND=">=sci-libs/libheinz-2.0.0 <sci-libs/libheinz-3"
RDEPEND="${DEPEND}"

src_prepare() {
	# Honor multilib layout: upstream hardcodes "DESTINATION lib" for the
	# shared library, which lands files in /usr/lib on amd64 instead of
	# /usr/lib64 and trips multilib-strict.
	sed -i -e 's|DESTINATION lib$|DESTINATION ${CMAKE_INSTALL_LIBDIR}|' \
		-e 's|DESTINATION lib)|DESTINATION ${CMAKE_INSTALL_LIBDIR})|' \
		ff/CMakeLists.txt || die

	# install(FILES ... DESTINATION cmake) → ${CMAKE_INSTALL_LIBDIR}/cmake/formfactor
	# Same fix as LibHeinz: install CMake package files where find_package()
	# searches by default (upstream targets ${prefix}/cmake/ which CMake
	# doesn't probe without a *_DIR hint).
	sed -i 's|DESTINATION cmake)|DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/formfactor)|g' \
		CMakeLists.txt || die

	# configure_package_config_file(... INSTALL_DESTINATION cmake) too,
	# so the generated formfactorConfig.cmake's PACKAGE_PREFIX_DIR math
	# resolves correctly from the new install location.
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
