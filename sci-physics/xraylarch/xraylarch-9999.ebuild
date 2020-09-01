# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_7 )

inherit distutils-r1 flag-o-matic git-r3

DESCRIPTION="Software for XRF data analysis"
HOMEPAGE="https://xraypy.github.io/xraylarch"
EGIT_REPO_URI="git://github.com/xraypy/xraylarch.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="doc python"

RDEPEND="
	>=dev-python/numpy-1.15[${PYTHON_USEDEP}]
	>=sci-libs/scipy-1.2[${PYTHON_USEDEP}]
	>=dev-python/six-1.10[${PYTHON_USEDEP}]
	>=dev-python/sqlalchemy-0.9[${PYTHON_USEDEP}]
	>=dev-python/h5py-2.8[${PYTHON_USEDEP}]
	>=sci-libs/scikits_learn-0.18[${PYTHON_USEDEP}]
	>=dev-python/pillow-3.4[${PYTHON_USEDEP}]
	>=dev-python/PeakUtils-1.3.0[${PYTHON_USEDEP}]
	>=dev-python/requests-2.1[${PYTHON_USEDEP}]
	>=sci-libs/lmfit-3.4
	>=dev-python/uncertainties-3.0.3[${PYTHON_USEDEP}]
	>=dev-python/asteval-0.9.18[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	dev-python/psutil[${PYTHON_USEDEP}]
	dev-python/termcolor[${PYTHON_USEDEP}]
	dev-python/wxpython:*[${PYTHON_USEDEP}]
	dev-python/wxmplot[${PYTHON_USEDEP}]
	dev-python/wxutils[${PYTHON_USEDEP}]
	sci-libs/scikits_image[${PYTHON_USEDEP}]
	dev-python/silx[${PYTHON_USEDEP}]
	dev-python/pytest[${PYTHON_USEDEP}]
	dev-python/pip[${PYTHON_USEDEP}]
	dev-python/xraydb[${PYTHON_USEDEP}]
	dev-python/nose[${PYTHON_USEDEP}]
	dev-python/pyshortcuts[${PYTHON_USEDEP}]
	>=dev-python/matplotlib-3.0[${PYTHON_USEDEP}]

	dev-python/pytest[${PYTHON_USEDEP}]
	dev-python/sphinx[${PYTHON_USEDEP}]
	dev-python/numpydoc[${PYTHON_USEDEP}]

	dev-python/PyQt5[${PYTHON_USEDEP}]
	dev-python/PyQtWebEngine[${PYTHON_USEDEP}]
	dev-python/fabio[${PYTHON_USEDEP}]
	dev-python/pyFAI[${PYTHON_USEDEP}]
	sci-libs/pycifrw[${PYTHON_USEDEP}]
"
#sphinxcontrib-bibtex #dev
#sphinxcontrib-argdoc #dev

DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
"
#	dev-python/pyepics
#	dev-python/tomopy
#for EPICS pyepics, psycopg2, epicsscan

S="${WORKDIR}/${PN}-${PV}"
DESTDIR="${D}"

PATCHES=(
	"${FILESDIR}"/full_conf.patch
	"${FILESDIR}"/py.patch
	"${FILESDIR}"/weird_patch_for_demeter
)

python_compile() {
	INSTALL_DIR="${D}"
	distutils-r1_python_compile
}

python_compile_all() {
	use doc && setup.py build
}

python_test() {
	setup.py test
}

python_install_all() {
	mkdir "${D}"/bin
	distutils-r1_python_install_all
}
