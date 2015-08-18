# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-2 eutils

DESCRIPTION="MPV front end"
HOMEPAGE="https://github.com/u8sand/Baka-MPlayer"
EGIT_REPO_URI="https://github.com/u8sand/Baka-MPlayer.git"

LICENSE="GPL-3"

SLOT="0"

KEYWORDS="~x86 ~amd64"

IUSE=""

DEPEND="
	media-video/mpv[libmpv]
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5
	dev-qt/qtsvg:5
	dev-qt/qtdeclarative:5
	dev-qt/qtx11extras:5
	"

RDEPEND="${DEPEND}"

src_prepare() {
	/usr/lib64/qt5/bin/qmake REFIX="${D}/usr src/Baka-MPlayer.pro"
}

src_install() {
	dobin build/baka-mplayer
	newicon etc/logo/64x64.png "${PN}".png
	make_desktop_entry baka-mplayer "Baka Mplayer"
}
