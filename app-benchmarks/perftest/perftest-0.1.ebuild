# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-benchmarks/perftest/perftest-0.1.ebuild,v 1 2013/01/14 17:04:35 megabaks Exp $

EAPI=5

inherit eutils

DESCRIPTION="Application designed to test gtk2/gtk3 performance"
HOMEPAGE="none"
SRC_URI="https://github.com/megabaks/test/raw/master/distfiles/${PN}.zip"

LICENSE="as-is"
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
