# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-benchmarks/qtperf/qtperf-0.1.ebuild,v 1 2010/12/06 00:13:35 megabaks Exp $

EAPI=2

inherit eutils

DESCRIPTION="Application designed to test QT performance"
HOMEPAGE=""
SRC_URI="http://www.corecrowd.com/qtperf.tar.bz2"

LICENSE=""
SLOT="0"
KEYWORDS="~alpha ~amd64 ~ppc64 ~sparc ~x86"
IUSE=""

DEPEND_COMMON="

		x11-libs/qt-gui
		x11-libs/qt-core
		dev-libs/glib
		sys-libs/glibc
	"
RDEPEND="
	${DEPEND_COMMON}
	"
DEPEND="
	${DEPEND_COMMON}
	"
S="${WORKDIR}/${PN}"

src_compile() {
	eqmake "$(use_enable nls)"
	emake || die "emake failed"
}

src_install() {
	insinto /usr/bin/
		dobin qtperf || die
}
