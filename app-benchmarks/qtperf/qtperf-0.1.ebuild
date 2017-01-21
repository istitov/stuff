# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils qt4-r2

DESCRIPTION="Application designed to test QT performance"
HOMEPAGE="none"
SRC_URI="http://stuff.tazhate.com/distfiles/${PN}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug"

DEPEND="dev-qt/qtgui:4
		dev-qt/qtcore:4
		dev-libs/glib:2"

RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}"

src_install() {
	insinto /usr/bin/
	dobin qtperf || die
}
