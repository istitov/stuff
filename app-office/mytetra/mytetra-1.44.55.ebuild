# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit qmake-utils

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

#https://github.com/xintrea/mytetra_dev/issues/133 has been used

src_prepare() {
	sed 's|/usr/local/bin|/usr/bin|' -i app/app.pro
	eapply_user
}

src_configure() {
	eqmake5 -recursive
}

src_compile() {
	emake -C "thirdParty/mimetex" -f Makefile.mimetex
	emake -C "app" -f Makefile.app
	emake
}

src_install() {
	emake install INSTALL_ROOT="${D}"
	einstalldocs
}
