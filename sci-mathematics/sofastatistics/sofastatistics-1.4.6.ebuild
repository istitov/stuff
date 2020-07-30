# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="sqlite"
inherit eutils python-single-r1

DESCRIPTION="SOFA is a statistics, analysis, and reporting program"
HOMEPAGE="https://sourceforge.net/projects/sofastatistics/"
SRC_URI="https://sourceforge.net/projects/sofastatistics/files/${PN}/${PV}/sofastats-${PV}.tar.gz/download# -> ${P}.tar.gz"
LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="-amd64 -x86"
IUSE="python"

# Workaround: please keep it sorted syncronous
L10Ns="br ca de-DE en-GB es-ES fr gl hr it mn pt-BR ru sl tr"
LANGS="br ca_ES de_DE en_GB es_ES fr_FR gl_ES hr_HR it_IT mn pt_BR ru_RU sl_SI tr_TR"

for lang in ${L10Ns}; do
	IUSE+=" l10n_${lang}"
done

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="dev-python/wxpython[${PYTHON_SINGLE_USEDEP}]
	dev-python/psycopg:2[${PYTHON_SINGLE_USEDEP}]
	dev-python/pyPdf[${PYTHON_SINGLE_USEDEP}]
	dev-python/numpy[${PYTHON_SINGLE_USEDEP}]
	dev-python/mysql-python[${PYTHON_SINGLE_USEDEP}]
	dev-python/pyxdg[${PYTHON_SINGLE_USEDEP}]
	dev-python/matplotlib[wxwidgets,${PYTHON_SINGLE_USEDEP}]
	dev-python/pythonmagick[${PYTHON_SINGLE_USEDEP}]
	media-gfx/wkhtmltopdf
	app-text/pdftk
	app-text/ghostscript-gpl"

#	dev-python/pywebkitgtk[${PYTHON_USEDEP}]
RDEPEND="${DEPEND}"

S="${WORKDIR}/sofastats-${PV}"

src_install(){
	for lang in ${LANGS};do
		use l10n_${lang} || rm -rf "sofa_main/locale/${lang}"
	done
	dodir /usr/share/sofastats
	insinto /usr/share/sofastats
	doins -r sofa_main/*
	exeinto /usr/share/sofastats
	doexe sofa_main/*.py*
	doexe sofa_main/*/*.py*
	python_fix_shebang "${ED}"
	dosym "${D}/usr/share/sofastats/start.py" "${D}/usr/bin/sofastats"
	make_desktop_entry sofastats ${PN} /usr/share/sofastats/images/sofa_32x32.ico "Science;"
}
