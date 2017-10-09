# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

EGIT_BRANCH="experimental"
EGIT_HAS_SUBMODULES="true"
EGIT_PROJECT="mytetra_dev"
EGIT_REPO_URI="git://github.com/xintrea/mytetra_dev.git"

inherit qt4-r2 versionator git-r3

DESCRIPTION="Smart manager for information collecting"
HOMEPAGE="https://github.com/xintrea/mytetra_dev"

LICENSE="GPL-3"
SLOT="0"
IUSE="debug"

RDEPEND=" dev-qt/qtgui:4
	  dev-qt/qtcore:4
	  dev-qt/qtxmlpatterns:4
	  dev-qt/qtsvg:4"

DEPEND="${RDEPEND}"

src_prepare(){
	sed 's|/usr/local/bin|/usr/bin|' -i mytetra.pro
}

src_install() {
	qt4-r2_src_install
	domenu desktop/mytetra.desktop
	doicon desktop/mytetra.png
}
