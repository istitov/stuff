# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils

DESCRIPTION="A clone of Super Mario Bros"
HOMEPAGE="http://stabyourself.net/mari0/"
SRC_URI="https://github.com/megabaks/test/raw/master/distfiles/${PN}-linux-${PV}.zip"

LICENSE="UoI-NCSA"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND=">=games-engines/love-0.8.0"

S=${WORKDIR}

src_install() {
	insinto /usr/share/mari0
	doins mari0_${PV}.love || die
	dobin ${FILESDIR}/mari0-${PV}
	
	insinto /usr/share/pixmaps
	newins ${FILESDIR}/icon.png mario.png
	make_desktop_entry mari0-${PV} "Mari0" mario
}

