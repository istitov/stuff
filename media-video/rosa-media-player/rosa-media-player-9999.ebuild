# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

inherit eutils qt4-r2 multilib git-2

DESCRIPTION="Multimedia player that supports most of audio and video formats."
HOMEPAGE="http://www.rosalab.ru/"
MY_PN="ROSA_Media_Player"
EGIT_REPO_URI="https://abf.rosalinux.ru/uxteam/${MY_PN}.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="media-video/mplayer"
DEPEND="${RDEPEND}
	dev-libs/glib
	dev-qt/qtcore:4
	dev-qt/qtgui:4
	dev-qt/qtmultimedia:4
	media-sound/wildmidi"

S="${WORKDIR}/${PN}"

src_compile() {
	cd ${PN}
	sed -i '1i#define OF(x) x' \
		src/findsubtitles/quazip/ioapi.{c,h} \
		src/findsubtitles/quazip/{zip,unzip}.h || die
	emake PREFIX=/usr || die
}

src_install() {
	cd "${PN}"
	emake PREFIX=/usr DESTDIR="${D}" install || die
}
