# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
PYTHON_COMPAT=( python3_{6,7,8} )

PYTHON_REQ_USE="sqlite"
inherit eutils python-single-r1 python-utils-r1 desktop

DESCRIPTION="SOFA is a statistics, analysis, and reporting program"
HOMEPAGE="https://sourceforge.net/projects/sofastatistics/"
SRC_URI="https://sourceforge.net/projects/sofastatistics/files/${PN}/${PV}/sofastats-${PV}.tar.gz/download# -> ${P}.tar.gz"
LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="python"

# Workaround: please keep it sorted syncronous
L10Ns="br ca de en es fr gl hr it mn pt ru sl tr"
LANGS="br ca de en es fr gl hr it mn pt ru sl tr"

for lang in ${L10Ns}; do
	IUSE+=" l10n_${lang}"
done

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="${PYTHON_DEPS}
	$(python_gen_cond_dep 'dev-python/wxpython[${PYTHON_USEDEP}]')
	$(python_gen_cond_dep 'dev-python/psycopg[${PYTHON_USEDEP}]')
	$(python_gen_cond_dep 'dev-python/PyPDF2[${PYTHON_USEDEP}]')
	$(python_gen_cond_dep 'dev-python/numpy[${PYTHON_USEDEP}]')
	$(python_gen_cond_dep 'dev-python/pyxdg[${PYTHON_USEDEP}]')
	$(python_gen_cond_dep 'dev-python/matplotlib[wxwidgets,${PYTHON_USEDEP}]')
	media-gfx/wkhtmltopdf
	app-text/pdftk
	app-text/ghostscript-gpl"
#	$(python_gen_cond_dep 'dev-python/mysql-python[${PYTHON_USEDEP}]')#no py3 yet
#	$(python_gen_cond_dep 'dev-python/pythonmagick[${PYTHON_USEDEP}]')#removed from the main tree
#	dev-python/pywebkitgtk[${PYTHON_USEDEP}]
RDEPEND="${DEPEND}"

#(?)python3-wxgtk4.0 (>= 4.0), python3-wxgtk-webview4.0 (>=4.0), libwxgtk-webview3.0-gtk3-0v5 (>=3.0),
#(+)python3-numpy (>= 1:1.13.1),python3-xdg (>= 0.25), python3-pymysql (>= 0.7), python3-matplotlib (>= 2.1.1), wkhtmltopdf (>= 0.12.4), ghostscript (>= 9), python3-pypdf2 (>= 1.26), 
#(-)python3-psycopg2 (>= 2.7.4)  imagemagick (>= 8.6.9) python3-openpyxl (>=2.4.9), python3-lxml (>=4.2.1)

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
	#python_fix_shebang "${ED}"/usr/share/sofastats/*.py #shebangs in the distro have some problems
	dosym "/usr/share/sofastats/start.py" "/usr/bin/sofastats"
	make_desktop_entry sofastats ${PN} /usr/share/sofastats/images/sofa_32x32.ico "Science;"
}
