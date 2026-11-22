# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

# Header-only logger, used only inside the library (BUILD_INTERFACE link).
# The release submodule pins a commit 12 behind this tag. verified 2026-11-07
PLOG_PV="1.1.11"

DESCRIPTION="WebRTC Data Channels, WebRTC Media Transport and WebSockets library"
HOMEPAGE="https://libdatachannel.org/
	https://github.com/paullouisageneau/libdatachannel"
SRC_URI="
	https://github.com/paullouisageneau/libdatachannel/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
	https://github.com/SergiusTheBest/plog/archive/refs/tags/${PLOG_PV}.tar.gz
		-> plog-${PLOG_PV}.gh.tar.gz
"

# MIT: plog, compiled into the library.
LICENSE="MPL-2.0 MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64 ~arm64"
IUSE="media test websocket"

# The suite connects peers through public STUN servers.
PROPERTIES="test_network"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-libs/openssl:=
	>=net-libs/libjuice-1.7.0:=
	net-libs/usrsctp
	media? ( net-libs/libsrtp:2= )
"
DEPEND="${RDEPEND}"

src_configure() {
	local mycmakeargs=(
		-DNO_EXAMPLES=ON
		-DNO_MEDIA=$(usex !media)
		-DNO_TESTS=$(usex !test)
		-DNO_WEBSOCKET=$(usex !websocket)
		-DUSE_GNUTLS=OFF
		-DUSE_MBEDTLS=OFF
		-DUSE_NICE=OFF
		-DUSE_SYSTEM_JUICE=ON
		-DUSE_SYSTEM_PLOG=ON
		-Dplog_INCLUDE_DIR="${WORKDIR}/plog-${PLOG_PV}/include"
		-DUSE_SYSTEM_SRTP=ON
		-DUSE_SYSTEM_USRSCTP=ON
		-DWARNINGS_AS_ERRORS=OFF
	)
	cmake_src_configure
}

src_test() {
	"${BUILD_DIR}"/tests || die "tests failed"
}
