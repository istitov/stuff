# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
DESCRIPTION="SVG Cleaner cleans up your SVG files from unnecessary data."
HOMEPAGE="http://qt-apps.org/content/show.php?action=content&content=147974 https://github.com/RazrFalcon/SVGCleaner"
EGIT_REPO_URI="https://github.com/RazrFalcon/SVGCleaner.git"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="git://github.com/RazrFalcon/${PN}.git"
	EGIT_BRANCH="master"
	KEYWORDS=""
	S="${WORKDIR}/${PN}"
else
	SRC_URI="https://github.com/RazrFalcon/${PN}/archive/v${PV}.zip -> ${P}.zip"
	KEYWORDS="~arm ~amd64 ~x86"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE=""

DEPEND="
app-arch/p7zip
>=dev-qt/qtsvg-4.6"
RDEPEND="${DEPEND}"
src_configure() {
	qmake \"PREFIX="${D}"\"
}
src_compile() {
	emake || die "Make failed!"
}
src_install() {
	emake install || die "Install failed"
	dodoc README
	dodoc INSTALL
}
