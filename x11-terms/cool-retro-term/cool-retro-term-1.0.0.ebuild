# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

EGIT_HAS_SUBMODULES="true"

inherit qmake-utils eutils

DESCRIPTION="A good looking terminal emulator which mimics the old cathode display"
HOMEPAGE="https://github.com/Swordfish90/cool-retro-term"
SRC_URI="https://github.com/Swordfish90/${PN}/archive/v${PV}.zip -> ${P}.zip"

LICENSE="GPL-3"

SLOT="0"

KEYWORDS="~x86 ~amd64"

IUSE=""

DEPEND="
	dev-qt/qtquickcontrols:5[widgets]
	dev-qt/qtgraphicaleffects:5
	dev-qt/qtdeclarative:5[localstorage]
	"

RDEPEND="${DEPEND}"

src_configure() {
	/usr/lib/qt5/bin/qmake INSTALL_PREFIX=/usr
}

src_install() {
	emake INSTALL_ROOT="${D}" install || die
}
