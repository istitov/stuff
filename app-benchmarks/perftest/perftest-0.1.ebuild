# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils

DESCRIPTION="Application designed to test gtk2/gtk3 performance"
HOMEPAGE="none"
SRC_URI="http://stuff.tazhate.com/distfiles/${PN}.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="	x11-libs/gtk+:2
			x11-libs/gtk+:3"

RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}"

src_compile(){
	emake clean
	emake
}

src_install() {
	dobin perftest_gtk{2,3} || die
}
