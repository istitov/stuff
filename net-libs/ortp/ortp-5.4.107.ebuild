# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Open Real-time Transport Protocol (RTP, RFC3550) stack"
HOMEPAGE="https://gitlab.linphone.org/BC/public/ortp"
SRC_URI="https://github.com/BelledonneCommunications/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="AGPL-3"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE="debug doc"

RDEPEND=">=net-libs/bctoolbox-5.3.0:="
DEPEND="${RDEPEND}"
BDEPEND="doc? ( app-text/doxygen )"

src_configure() {
	local mycmakeargs=(
		-DENABLE_DOC=$(usex doc)
		-DENABLE_DEBUG_LOGS=$(usex debug)
		-DENABLE_STRICT=OFF
		-DENABLE_TESTS=OFF
		-DENABLE_UNIT_TESTS=OFF
	)
	cmake_src_configure
}
