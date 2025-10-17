# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Utilities library used by Belledonne Communications softwares"
HOMEPAGE="https://www.linphone.org/ https://savannah.nongnu.org/projects/linphone/"
SRC_URI="http://www.linphone.org/releases/old/sources/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	net-libs/mbedtls"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs=(
		-DENABLE_MBEDTLS=YES
		-DENABLE_POLARSSL=NO
		-DENABLE_TESTS=NO
		-DENABLE_TESTS_COMPONENT=NO
	)
	cmake_src_configure
}
