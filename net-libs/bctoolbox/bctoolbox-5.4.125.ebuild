# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Utilities library used by Belledonne Communications projects"
HOMEPAGE="https://github.com/BelledonneCommunications/bctoolbox"
SRC_URI="https://github.com/BelledonneCommunications/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~arm64 ~x86"

# Upstream assumes a modified Mbed TLS with MBEDTLS_THREADING_ALT; Gentoo's
# Mbed TLS uses MBEDTLS_THREADING_PTHREAD and cannot build this backend.
RDEPEND="dev-libs/openssl:="
DEPEND="${RDEPEND}"

src_configure() {
	local mycmakeargs=(
		-DENABLE_MBEDTLS=OFF
		-DENABLE_OPENSSL=ON
		-DENABLE_DECAF=OFF
		-DENABLE_TESTS_COMPONENT=OFF
		-DENABLE_UNIT_TESTS=OFF
		-DENABLE_STRICT=OFF
	)
	cmake_src_configure
}
