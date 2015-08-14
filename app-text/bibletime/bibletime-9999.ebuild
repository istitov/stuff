# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit cmake-utils git-2

DESCRIPTION="Qt Bible study application using the SWORD library"
HOMEPAGE="http://www.bibletime.info/"
EGIT_REPO_URI="https://github.com/bibletime/bibletime.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="debug"

# bug 313657
# RESTRICT="test"

RDEPEND="
	>=app-text/sword-1.6.0
	>=dev-cpp/clucene-2.3.3.4
	dev-qt/linguist-tools:5
	dev-qt/qtcore:5
	dev-qt/qtdbus:5
	dev-qt/qtprintsupport:5
	dev-qt/qtwidgets:5
	dev-qt/qtsvg:5
	dev-qt/qtwebkit:5
	dev-qt/qtprintsupport:5
	dev-qt/qtxml:5
	dev-qt/qtdbus:5
"
DEPEND="
	${RDEPEND}
	dev-libs/boost
	dev-libs/icu:=
	net-misc/curl
	sys-libs/zlib
	dev-qt/qttest:5
"

DOCS=( ChangeLog README )

src_prepare() {
	sed -e "s:Dictionary;Qt:Dictionary;Office;TextTools;Utility;Qt:" \
	    -i cmake/platforms/linux/bibletime.desktop.cmake || die "fixing .desktop file failed"
}

src_configure() {
	local mycmakeargs=(
		-DUSE_QT_WEBKIT=ON
	)
	cmake-utils_src_configure
}
