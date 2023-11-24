# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit cmake
DESCRIPTION="Disk fragmentation viewer written with boost and gtkmm"
HOMEPAGE="https://github.com/i-rinat/fragview"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/i-rinat/fragview.git"
	EGIT_BRANCH="master"
else
	SRC_URI="https://github.com/i-rinat/${PN}/archive/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-2 Boost-1.0"
SLOT="0"

DEPEND="
	dev-libs/boost
	dev-cpp/gtkmm:3.0"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}/cmake-patch.patch"
}

src_install() {
	cmake_src_install
	dodoc README.md || die "Install failed"
}
