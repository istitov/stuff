# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils qt4-r2
SRC_URI="https://downloads.sourceforge.net/project/${PN}.berlios/${P}.tgz"

DESCRIPTION="Viewer for IETF RFCs"
HOMEPAGE="http://qrfcview.berlios.de/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="x11-libs/qt-core
		x11-libs/qt-gui"
DEPEND="${RDEPEND}"

src_prepare() {
		epatch "${FILESDIR}"/${PN}-include-stdint-h.patch
}

src_install() {
		insinto /usr/bin/
		dobin bin/qRFCView || die
}
