# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="4"

inherit qt4-r2

DESCRIPTION="Vector metro (subway) map for calculating route and getting information about transport nodes."
HOMEPAGE="http://sourceforge.net/projects/qmetro/"
SRC_URI="mirror://sourceforge/${PN}/${P}.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug"

RDEPEND="
	dev-qt/qtgui:4
	dev-qt/qt-mobility[multimedia]"
DEPEND="${RDEPEND}
	app-arch/unzip"

DOCS="AUTHORS README"

src_prepare() {
	default
	sed -i -e 's,src/zlib/,,' src/zip/zip.h src/zip/unzip.h || die
	rm -r src/zlib/ || die
}

src_configure(){
	LDFLAGS+="-lz" qt4-r2_src_configure
}
