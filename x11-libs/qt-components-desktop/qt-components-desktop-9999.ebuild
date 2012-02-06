# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

EGIT_REPO_URI="git://gitorious.org/qt-components/desktop.git"
inherit qt4-r2 git-2

DESCRIPTION="Qt4 desktop components"
HOMEPAGE="http://qt.gitorious.org/qt-components"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="debug"

DEPEND=">=x11-libs/qt-declarative-4.7.4
"

RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}"

src_configure() {
	eqmake4 desktop.pro PREFIX="/usr"
}
