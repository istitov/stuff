# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
PYTHON_REQ_USE="sqlite"

inherit desktop python-single-r1

DESCRIPTION="SOFA is a statistics, analysis, and reporting program"
HOMEPAGE="https://www.sofastatistics.com/ https://sourceforge.net/projects/sofastatistics/"
SRC_URI="https://sourceforge.net/projects/sofastatistics/files/${PN}/${PV}/sofastats-${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/sofastats-${PV}"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

LANGS="br ca de en es fr gl hr it mn pt ru sl tr"
for lang in ${LANGS}; do
	IUSE+=" l10n_${lang}"
done

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/matplotlib[wxwidgets,${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/psycopg[${PYTHON_USEDEP}]
		dev-python/pypdf[${PYTHON_USEDEP}]
		dev-python/pyxdg[${PYTHON_USEDEP}]
		dev-python/wxpython[${PYTHON_USEDEP}]
	')
	app-text/ghostscript-gpl
"
DEPEND="${RDEPEND}"

pkg_setup() {
	python-single-r1_pkg_setup
}

src_install() {
	local lang
	for lang in ${LANGS}; do
		use "l10n_${lang}" || rm -rf "sofa_main/locale/${lang}"
	done
	insinto /usr/share/sofastats
	doins -r sofa_main/*
	exeinto /usr/share/sofastats
	doexe sofa_main/*.py*
	doexe sofa_main/*/*.py*
	dosym ../share/sofastats/start.py /usr/bin/sofastats
	make_desktop_entry sofastats ${PN} /usr/share/sofastats/images/sofa_32x32.ico "Science;"
}

pkg_postinst() {
	elog
	elog "SOFA's PDF and image export features call out to wkhtmltopdf"
	elog "and pdftk at runtime, but neither is in ::gentoo any more."
	elog "All other functionality works without them."
	elog
}
