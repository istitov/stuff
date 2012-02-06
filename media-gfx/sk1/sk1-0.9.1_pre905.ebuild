# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

PYTHON_DEPEND="2"
PYTHON_USE_WITH="tk"

inherit distutils eutils

MY_PN="sK1"
MY_PV="${PV/_pre/pre_rev}"
MY_P="${MY_PN}-${PV%_p*}pre"
DESCRIPTION="sK1 vector graphics editor"
HOMEPAGE="http://www.sk1project.org"
SRC_URI="http://sk1project.org/downloads/${PN}/${MY_PV}/${MY_PN}-${MY_PV}.tar.gz"

LICENSE="|| ( GPL-2 LGPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gnome kde"

DEPEND="
	dev-lang/python
	>=dev-lang/tcl-8.5.0
	>=dev-lang/tk-8.5.0
	dev-python/imaging[tk]
	media-libs/freetype:2
	>=sys-libs/zlib-1.1.4
	>=x11-libs/cairo-1.2.4
	x11-libs/libX11
	x11-libs/libXext"
RDEPEND="${DEPEND}
	dev-python/reportlab
	app-text/ghostscript-gpl
	gnome? ( gnome-extra/zenity )
	kde? ( kde-base/kdialog )
	~media-libs/sk1libs-${PV}"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup

	ewarn "Without composite window manager interface may be slow."
}

src_install() {
	distutils_src_install

	newicon src/share/icons/CrystalSVG/icon_sk1_64.png sk1.png
	make_desktop_entry ${PN} "${MY_PN}" ${PN} "Graphics;VectorGraphics;"
}