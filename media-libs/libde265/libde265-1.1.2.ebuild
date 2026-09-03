# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake-multilib

DESCRIPTION="Open h.265 video codec implementation"
HOMEPAGE="https://github.com/strukturag/libde265"

# Upstream commit 8b305cb ('remove en265 and dev-tools from distribution
# tarball') strips enc265/ and dev-tools/ from the release tarball. The
# live (git) ebuild fetches the full tree and can therefore expose
# USE=enc265 and USE=tools; the release ebuild's IUSE is the narrower
# buildable subset. Verified 2026-05-26 against v1.1.0.
if [[ ${PV} == *9999 ]] ; then
	EGIT_REPO_URI="https://github.com/strukturag/${PN}.git"
	inherit git-r3
	IUSE="dec265 enc265 sdl tools"
	LICENSE="LGPL-3+ dec265? ( MIT ) enc265? ( MIT ) tools? ( GPL-3+ )"
else
	SRC_URI="https://github.com/strukturag/libde265/releases/download/v${PV}/${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~loong ~ppc64 ~riscv ~x86"
	IUSE="dec265 sdl"
	LICENSE="LGPL-3+ dec265? ( MIT )"
fi

SLOT="0"

RDEPEND="
	dec265? (
		sdl? ( media-libs/libsdl2 )
	)
"
DEPEND="${RDEPEND}"

multilib_src_configure() {
	# sherlock265 (Qt visual inspector) needs media-libs/libvideogfx (not
	# in ::gentoo) or media-libs/libswscale; force-disabled.
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
		-DENABLE_SIMD=ON
		-DENABLE_SHERLOCK265=OFF
		-DUSE_IWYU=OFF
		-DWITH_FUZZERS=OFF
		-DENABLE_DECODER=$(multilib_native_usex dec265)
		-DENABLE_SDL=$(multilib_native_usex sdl)
	)
	if [[ ${PV} == *9999 ]] ; then
		mycmakeargs+=(
			-DENABLE_ENCODER=$(multilib_native_usex enc265)
			-DENABLE_INTERNAL_DEVELOPMENT_TOOLS=$(multilib_native_usex tools)
		)
	else
		mycmakeargs+=(
			-DENABLE_ENCODER=OFF
			-DENABLE_INTERNAL_DEVELOPMENT_TOOLS=OFF
		)
	fi
	cmake_src_configure
}
