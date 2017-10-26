# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit cmake-utils
DESCRIPTION="Disk fragmentation viewer written with boost and gtkmm"
HOMEPAGE="https://github.com/i-rinat/fragview"
SRC_URI="https://github.com/i-rinat/fragview/archive/v0.1.1.tar.gz"

LICENSE="GPL-2 Boost-1.0"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="
dev-libs/boost
dev-cpp/gtkmm:3.0"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}/cmake-patch.patch"
}

src_install() {
	cmake-utils_src_install
	dodoc README.md || die "Install failed"
}
