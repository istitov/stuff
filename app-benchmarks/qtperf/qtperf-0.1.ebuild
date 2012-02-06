# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-benchmarks/qtperf/qtperf-0.1.ebuild,v 1 2010/12/06 00:13:35 megabaks Exp $

EAPI=4

inherit eutils qt4-r2

DESCRIPTION="Application designed to test QT performance"
HOMEPAGE="none"
SRC_URI="https://github.com/megabaks/test/raw/master/distfiles/qtperf.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug"

DEPEND="
		x11-libs/qt-gui
		x11-libs/qt-core
		dev-libs/glib
	"
RDEPEND="
	${DEPEND}
	"
S="${WORKDIR}/${PN}"

src_install() {
	insinto /usr/bin/
		dobin qtperf || die
}
