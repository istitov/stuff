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
KEYWORDS="~amd64"

src_prepare() {
	# install(FILES ... DESTINATION cmake) → ${CMAKE_INSTALL_LIBDIR}/cmake/LibHeinz
	# Upstream installs LibHeinzConfig.cmake to ${prefix}/cmake/ which CMake's
	# find_package() doesn't search by default. Patch to a standard location
	# so consumers (libformfactor, bornagain) resolve LibHeinz without
	# needing a LibHeinz_DIR override.
	sed -i 's|DESTINATION cmake |DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/LibHeinz |' \
		CMakeLists.txt || die

	# Upstream's configure_package_config_file still references a
	# vestigial "lib/cmake/example" template path — patch to match the
	# real install destination so the generated config's relative-path
	# math stays correct if upstream ever adds imported targets.
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
