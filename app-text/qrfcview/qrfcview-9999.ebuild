# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit eutils qt4-r2 git-r3
EGIT_REPO_URI="https://github.com/saghul/qrfcview-osx.git"

DESCRIPTION="Viewer for IETF RFCs"
HOMEPAGE="http://qrfcview.berlios.de/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="dev-qt/qtcore
		dev-qt/qtgui"
DEPEND="${RDEPEND}"

src_prepare() {
		epatch "${FILESDIR}"/${PN}-include-stdint-h.patch
}

src_install() {
		insinto /usr/bin/
		dobin bin/qRFCView || die
}
