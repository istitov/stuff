# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake-multilib

DESCRIPTION="Open h.265 video codec implementation"
HOMEPAGE="https://github.com/strukturag/libde265"

if [[ ${PV} == *9999 ]] ; then
	EGIT_REPO_URI="https://github.com/strukturag/${PN}.git"
	inherit git-r3
else
	SRC_URI="https://github.com/strukturag/libde265/releases/download/v${PV}/${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~loong ~ppc64 ~riscv ~x86"
fi

LICENSE="LGPL-3+ dec265? ( MIT )"
SLOT="0"
IUSE="dec265 sdl"

RDEPEND="
	dec265? (
		sdl? ( media-libs/libsdl2 )
	)
"
DEPEND="${RDEPEND}"

multilib_src_configure() {
	# The release tarball intentionally omits enc265/ and dev-tools/ per
	# upstream commit 8b305cb ('remove en265 and dev-tools from distribution
	# tarball'). ENABLE_ENCODER and ENABLE_INTERNAL_DEVELOPMENT_TOOLS are
	# pinned OFF; enabling them via cmake would fail at add_subdirectory.
	# sherlock265 (Qt visual inspector) needs media-libs/libvideogfx (not
	# in ::gentoo) or media-libs/libswscale; force-disabled.
	# Verified 2026-05-26 against v1.1.0 release tarball.
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
		-DENABLE_SIMD=ON
		-DENABLE_ENCODER=OFF
		-DENABLE_INTERNAL_DEVELOPMENT_TOOLS=OFF
		-DENABLE_SHERLOCK265=OFF
		-DUSE_IWYU=OFF
		-DWITH_FUZZERS=OFF
		-DENABLE_DECODER=$(multilib_native_usex dec265)
		-DENABLE_SDL=$(multilib_native_usex sdl)
	)
	cmake_src_configure
}
