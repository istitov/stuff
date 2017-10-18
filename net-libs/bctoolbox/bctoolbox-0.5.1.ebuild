# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

DESCRIPTION="Utilities library used by Belledonne Communications softwares"
HOMEPAGE="https://www.linphone.org/ https://savannah.nongnu.org/projects/linphone/"
SRC_URI="http://www.linphone.org/releases/sources/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+mbedtls polarssl"
#-test"

DEPEND="
	polarssl? ( net-libs/polarssl )
	mbedtls? ( net-libs/mbedtls )"
#	test? ( >=dev-util/bcunit-3.0.2 )"
RDEPEND="${DEPEND}"
pkg_setup() {
	if use polarssl && use mbedtls; then
		eerror "You can select either polarssl or mbedtls, but not both at the same time" && die
	fi
}

src_configure() {
	local mycmakeargs=(
		-DENABLE_MBEDTLS="$(usex mbedtls)"
		-DENABLE_POLARSSL="$(usex polarssl)"
		-DENABLE_TESTS=NO
		-DENABLE_TESTS_COMPONENT=NO
	)
	cmake-utils_src_configure
}
