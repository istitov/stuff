# Copyright 1999-2013 Gentoo Foundation
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

RDEPEND="dev-qt/qtcore
		dev-qt/qtgui"
DEPEND="${RDEPEND}"

src_prepare() {
		epatch "${FILESDIR}"/${PN}-include-stdint-h.patch
		epatch "${FILESDIR}"/${PN}-increase-max-rfc-num.patch
}

src_install() {
		insinto /usr/bin/
		dobin bin/qRFCView || die
}
