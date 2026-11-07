# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="UDP Interactive Connectivity Establishment (ICE) library"
HOMEPAGE="https://github.com/paullouisageneau/libjuice"
SRC_URI="https://github.com/paullouisageneau/libjuice/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="MPL-2.0"
SLOT="0/$(ver_cut 1)"
KEYWORDS="~amd64 ~arm64"
IUSE="test"

# The suite gathers candidates from public STUN/TURN servers.
PROPERTIES="test_network"
RESTRICT="!test? ( test )"

PATCHES=(
	# The Smack LSM rejects an AF_INET destination on a dual-stack socket,
	# which broke every IPv4 STUN request. verified 2026-11-07
	"${FILESDIR}/${P}-linux-v4mapped-sendto.patch"
)

src_configure() {
	local mycmakeargs=(
		-DNO_TESTS=$(usex !test)
		-DWARNINGS_AS_ERRORS=OFF
	)
	cmake_src_configure
}

src_test() {
	"${BUILD_DIR}"/tests || die "tests failed"
}
