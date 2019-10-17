# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit qmake-utils eapi7-ver

DESCRIPTION="Smart manager for information collecting"
HOMEPAGE="https://github.com/xintrea/mytetra_dev"

if [[ ${PV} == "9999" ]] ; then
	inherit git-r3
	EGIT_BRANCH="experimental"
	EGIT_REPO_URI="https://github.com/xintrea/mytetra_dev.git"
else
	SRC_URI="https://github.com/xintrea/${PN}_dev/archive/v.${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86"
	S="${WORKDIR}/${PN}_dev-v.${PV}/"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="debug"

RDEPEND="dev-qt/qtgui:5
	dev-qt/qtcore:5
	dev-qt/qtxmlpatterns:5
	dev-qt/qtsvg:5"

DEPEND="${RDEPEND}"

src_prepare(){
	sed 's|/usr/local/bin|/usr/bin|' -i mytetra.pro
}

src_compile(){
	qmake
}

src_install() {
	emake install INSTALL_ROOT="${D}"
	einstalldocs
}
