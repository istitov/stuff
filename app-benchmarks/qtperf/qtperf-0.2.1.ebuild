# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-benchmarks/qtperf/qtperf-0.1.ebuild,v 1 2010/12/06 00:13:35 megabaks Exp $

EAPI=4

inherit eutils qt4-r2

DESCRIPTION="Application designed to test QT performance"
HOMEPAGE="http://code.google.com/p/qtperf/"
SRC_URI="http://qtperf.googlecode.com/files/${P}.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug"

RDEPEND="
		x11-libs/qt-gui
		x11-libs/qt-core
		dev-libs/glib
	"
DEPEND="
	${RDEPEND}
	"
S="${WORKDIR}/${PN}"
MY_PN="${PN}4"
src_install() {
	into /usr/
	newbin "${MY_PN}" "${PN}" || die "Can't install ${PN}"

}
