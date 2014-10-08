# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/shotcut/shotcut-9999.ebuild,v 1.1 2014-08-31 13:19:13 brothermechanic Exp $

EAPI=4

inherit git-2 eutils

DESCRIPTION="A free, open source, cross-platform video editor"
HOMEPAGE="http://www.shotcut.org/"
EGIT_REPO_URI="https://github.com/mltframework/shotcut.git"

LICENSE="GPL-3"

SLOT="0"

KEYWORDS="~x86 ~amd64"

IUSE=""

DEPEND="
	=media-libs/mlt-9999
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtx11extras:5
	dev-qt/qtsql:5
	dev-qt/qtwebkit:5
	dev-qt/qtquickcontrols:5
	dev-qt/qtnetwork:5
	dev-qt/qtxml:5
	dev-qt/qtopengl:5
	dev-qt/qtwidgets:5
	dev-qt/qtconcurrent:5
	=media-video/ffmpeg-2*
	media-libs/x264
	media-libs/libvpx
	media-sound/lame
	media-plugins/frei0r-plugins
	media-libs/ladspa-sdk
	"

RDEPEND="${DEPEND}"


src_prepare() {
	/usr/lib64/qt5/bin/qmake PREFIX=D/usr/
}

src_install() {
	emake DESTDIR="${D}" install
}
