# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="2"

EGIT_REPO_URI="https://gitorious.org/qtplayground/qtdesktopcomponents.git"
EGIT_BRANCH="qt4"

inherit qt4-r2 git-r3

DESCRIPTION="Qt4 desktop components"
HOMEPAGE="http://qt.gitorious.org/qt-components"

LICENSE="GPL-3"
SLOT="4"
KEYWORDS=""
IUSE="debug"

DEPEND=">=dev-qt/qtdeclarative-4.7.4
"

RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}"

src_configure() {
	eqmake4 desktop.pro PREFIX="/usr"
}
