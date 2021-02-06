# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="tk(+)"

inherit distutils-r1 eutils

MY_PN="sK1"
DESCRIPTION="sK1 vector graphics editor"
HOMEPAGE="http://www.sk1project.org"
SRC_URI="mirror://sourceforge/project/${PN}/${PN}/${MY_PN}_v.${PV}/${PN}-${PV}.tar.gz"
LICENSE="|| ( GPL-2 LGPL-2 )"
SLOT="0.9"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-lang/python:2.7
	dev-lang/tcl:0
	dev-lang/tk:0
	media-libs/freetype:2
	>=sys-libs/zlib-1.1.4
	>=x11-libs/cairo-1.2.4
	media-libs/lcms:2
	dev-python/pycairo
	dev-python/pillow
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXcursor"
RDEPEND="${DEPEND}
	dev-python/reportlab
	app-text/ghostscript-gpl"

src_install() {
	distutils-r1_src_install
	newicon src/sk1/share/images/sk1-app-icon.png sk1.png
	make_desktop_entry ${PN} "${MY_PN}" ${PN} "Graphics;VectorGraphics;"
}
