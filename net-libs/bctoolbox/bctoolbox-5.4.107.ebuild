# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Utilities library used by Belledonne Communications projects"
HOMEPAGE="https://gitlab.linphone.org/BC/public/bctoolbox"
SRC_URI="https://github.com/BelledonneCommunications/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE="mbedtls +openssl"
REQUIRED_USE="|| ( mbedtls openssl )"

# mbedtls support assumes upstream-style builds with MBEDTLS_THREADING_ALT;
# Gentoo's net-libs/mbedtls v3 uses MBEDTLS_THREADING_PTHREAD instead, so
# bctoolbox fails to compile against it. Default to openssl until that is
# fixed (upstream or by patching bctoolbox to use pthread).
RDEPEND="
	mbedtls? ( >=net-libs/mbedtls-3 )
	openssl? ( dev-libs/openssl:= )
"
DEPEND="${RDEPEND}"

src_configure() {
	local mycmakeargs=(
		-DENABLE_MBEDTLS=$(usex mbedtls)
		-DENABLE_OPENSSL=$(usex openssl)
		-DENABLE_DECAF=OFF
		-DENABLE_TESTS_COMPONENT=OFF
		-DENABLE_UNIT_TESTS=OFF
		-DENABLE_STRICT=OFF
	)

	# Gentoo's net-libs/mbedtls v3 lives in /usr/include/mbedtls3/ so
	# v2 and v3 can coexist. Upstream's FindMbedTLS.cmake only searches
	# the default include path; point it at v3 explicitly.
	if use mbedtls; then
		mycmakeargs+=(
			-DCMAKE_INCLUDE_PATH="${ESYSROOT}/usr/include/mbedtls3"
		)
	fi

	cmake_src_configure
}
