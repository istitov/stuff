# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

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
LANGS="br ca_ES de_DE en_GB es_ES fr_FR gl_ES hr_HR it_IT mn pt_BR ru_RU sl_SI tr_TR"
for lang in ${LANGS}; do
	IUSE+=" linguas_${lang}"
done

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="dev-python/wxpython:2.8[${PYTHON_USEDEP}]
		dev-python/psycopg:2[${PYTHON_USEDEP}]
		dev-python/pyPdf[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/mysql-python[${PYTHON_USEDEP}]
		dev-python/pyxdg[${PYTHON_USEDEP}]
		dev-python/matplotlib[wxwidgets,${PYTHON_USEDEP}]
		dev-python/pywebkitgtk[${PYTHON_USEDEP}]
		dev-python/pythonmagick[${PYTHON_USEDEP}]
		media-gfx/wkhtmltopdf
		app-text/pdftk
		app-text/ghostscript-gpl"

RDEPEND="${DEPEND}"

S="${WORKDIR}/sofastats-${PV}"

src_install(){
	for lang in ${LANGS};do
		use linguas_${lang} || rm -rf "sofa_main/locale/${lang}"
	done
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
