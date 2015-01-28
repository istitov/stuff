# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-terms/cool-retro-term/cool-retro-term-9999.ebuild,v 0.1 2014-11-11 13:19:13 brothermechanic Exp $

EAPI=5

EGIT_HAS_SUBMODULES="true"

inherit git-2 eutils

DESCRIPTION="A good looking terminal emulator which mimics the old cathode display"
HOMEPAGE="https://github.com/Swordfish90/cool-retro-term"
EGIT_REPO_URI="git://github.com/Swordfish90/cool-retro-term.git"

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
