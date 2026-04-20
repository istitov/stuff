# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake xdg

DESCRIPTION="Graphical user interface for HTTrack library, developed in C++ and based on Qt"
HOMEPAGE="http://httraqt.sourceforge.net"
SRC_URI="https://downloads.sourceforge.net/${PN}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"

RDEPEND="
	dev-qt/qtbase:6[dbus,gui,widgets]
	dev-qt/qtmultimedia:6
	>=www-client/httrack-3.45.4
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-qt/qttools:6[linguist]
"

src_configure() {
	local mycmakeargs=(
		-DUSE_QT_VERSION=6
	)
	cmake_src_configure
}
