# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

PYTHON_COMPAT=( python2_7 )
PYTHON_USE_WITH="tk"

inherit distutils-r1 eutils

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
	dev-lang/python:2.7
	dev-lang/tcl:0
	dev-lang/tk:0
	media-libs/freetype:2
	>=sys-libs/zlib-1.1.4
	>=x11-libs/cairo-1.2.4
	x11-libs/libX11
	x11-libs/libXext"
RDEPEND="${DEPEND}
	dev-python/reportlab
	app-text/ghostscript-gpl
	gnome? ( gnome-extra/zenity )
	kde? ( kde-apps/kdialog:4/4.14 )
	~media-libs/sk1libs-${PV}"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup

	ewarn "Without composite window manager interface may be slow."
}

src_install() {
	distutils-r1_src_install

	newicon src/share/icons/CrystalSVG/icon_sk1_64.png sk1.png
	make_desktop_entry ${PN} "${MY_PN}" ${PN} "Graphics;VectorGraphics;"
}
