# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"
PYTHON_COMPAT=( python{2_6,2_7} )
PYTHON_USE_WITH="sqlite"
inherit eutils python-single-r1

DESCRIPTION="SOFA is a statistics, analysis, and reporting program"
HOMEPAGE="http://sourceforge.net/projects/sofastatistics/"
SRC_URI="http://sourceforge.net/projects/sofastatistics/files/${PN}/${PV}/sofastats-${PV}.tar.gz/download# -> ${P}.tar.gz"
LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="dev-python/wxpython:2.8
		dev-python/psycopg:2
		media-gfx/wkhtmltopdf
		app-text/pdftk
		dev-python/pyPdf
		>=dev-python/numpy-1.5.1
		>=dev-python/mysql-python-1.2.3
		dev-python/pyxdg
		dev-python/matplotlib
		dev-python/pywebkitgtk
		>=media-gfx/imagemagick-6.8.6.1
		dev-python/pythonmagick"

RDEPEND="${DEPEND}"

S="${WORKDIR}/sofastats-${PV}"

src_install(){
	dodir /usr/share/sofastats
	insinto /usr/share/sofastats
	doins -r sofa_main/*
	exeinto /usr/share/sofastats
	doexe sofa_main/*.py*
	doexe sofa_main/*/*.py*
	python_fix_shebang "${ED}"
	dosym /usr/share/sofastats/start.py /usr/bin/sofastats
	make_desktop_entry sofastats ${PN} /usr/share/sofastats/images/sofa_32x32.ico "Science;"
}
