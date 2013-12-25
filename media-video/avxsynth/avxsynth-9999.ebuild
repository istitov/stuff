# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/avxsynth/avxsynth-9999.ebuild,v 1.1 2013/12/24 16:11:23 brothermechanic Exp $

EAPI=5

inherit git-2 autotools eutils

DESCRIPTION="A Linux port of the AviSynth toolkit"
HOMEPAGE="https://github.com/avxsynth/avxsynth"
EGIT_REPO_URI="https://github.com/avxsynth/avxsynth.git"
EGIT_BRANCH="master"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-libs/log4cpp
	dev-qt/qtgui
	media-video/mplayer2
	sys-devel/autoconf
	sys-devel/automake
	x11-libs/cairo
	virtual/ffmpeg
	virtual/jpeg
	media-libs/ffmpegsource"

RDEPEND=""

src_prepare() {
	epatch "${FILESDIR}"/ldconfig.patch
        eautoreconf -if
} 

scr_configure() {
	econf --prefix=/usr --enable-silent-rules --with-pic
}

src_install() {
	einstall || die "einstall failed"
	newicon apps/AVXEdit/images/mplayer.png "${PN}".png
        make_desktop_entry AVXEdit
}

pkg_postinst() {
	ln -s /usr/bin/mplayer2 /usr/bin/mplayer
	echo "a portage created the symlink /usr/bin/mplayer"
}
pkg_postrm() {
	rm /usr/bin/mplayer
}
