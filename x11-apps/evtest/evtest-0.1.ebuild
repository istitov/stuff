# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/evtest/evtest-0.1.ebuild,v 1 2010/12/06 00:13:35 megabaks Exp $

EAPI=2

inherit eutils

DESCRIPTION="evtest monitors an input device, displaying all the events it generates."
HOMEPAGE="http://code.google.com/p/beagleboard/"
SRC_URI="http://beagleboard.googlecode.com/files/evtest.c"

LICENSE=""
SLOT="0"
KEYWORDS="~alpha ~amd64 ~ppc64 ~sparc ~x86"
IUSE=""

src_prepare() {
	cp ../distdir/evtest.c .
}

src_compile() {
	gcc -o evtest evtest.c || die "compile failed"
}

src_install() {
	insinto /usr/bin/
	dobin evtest || die
}
