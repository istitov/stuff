# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit eutils qmake-utils
SRC_URI="https://downloads.sourceforge.net/project/${PN}.berlios/${P}.tgz"

DESCRIPTION="Viewer for IETF RFCs"
HOMEPAGE="https://sourceforge.net/projects/qrfcview.berlios/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-qt/qtcore
	dev-qt/qtgui"
DEPEND="${RDEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-include-stdint-h.patch
	epatch "${FILESDIR}"/${PN}-fixed-rfc-number-limit.patch
	epatch "${FILESDIR}"/01-removal-of-spurious-debug-output.patch
}

src_install() {
	insinto /usr/bin/
	dobin bin/qRFCView || die
	doman "${FILESDIR}"/qRFCView.1 || die
}
