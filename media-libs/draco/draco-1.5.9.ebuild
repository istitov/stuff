# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="3D mesh and point-cloud compression library"
HOMEPAGE="https://google.github.io/draco/
	https://github.com/google/draco"
SRC_URI="https://github.com/google/draco/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
# Subslot follows the soname: 1.5.9 moved libdraco.so.10 to .so.11.
# verified 2026-10-17
SLOT="0/11"
KEYWORDS="~amd64 ~arm ~arm64"

PATCHES=( "${FILESDIR}"/${PN}-1.5.7-no-static-with-shared.patch )

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
		-DDRACO_TESTS=OFF
		-DDRACO_TRANSCODER_SUPPORTED=OFF
		-DDRACO_PMC_SUPPORTED=OFF
	)
	cmake_src_configure
}
