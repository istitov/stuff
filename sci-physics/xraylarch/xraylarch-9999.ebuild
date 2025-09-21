# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..11} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 git-r3

DESCRIPTION="Software for XRF data analysis"
HOMEPAGE="https://xraypy.github.io/xraylarch"
EGIT_REPO_URI="https://github.com/xraypy/xraylarch.git"

LICENSE="GPL-2"
SLOT="0"
IUSE="doc python"
RESTRICT=strip

RDEPEND="
	>=dev-python/numpy-1.15[${PYTHON_USEDEP}]
	>=dev-python/scipy-1.2[${PYTHON_USEDEP}]
	>=dev-python/six-1.10[${PYTHON_USEDEP}]
	>=dev-python/sqlalchemy-0.9[${PYTHON_USEDEP}]
	>=dev-python/h5py-2.8[${PYTHON_USEDEP}]
	>=dev-python/scikit-learn-0.18[${PYTHON_USEDEP}]
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
	dev-python/lmfit[${PYTHON_USEDEP}]
	dev-python/scikit-image[${PYTHON_USEDEP}]
	dev-python/silx[${PYTHON_USEDEP}]
	dev-python/pytest[${PYTHON_USEDEP}]
	dev-python/pip[${PYTHON_USEDEP}]
	dev-python/xraydb[${PYTHON_USEDEP}]
	dev-python/pyshortcuts[${PYTHON_USEDEP}]
	>=dev-python/matplotlib-3.0[${PYTHON_USEDEP}]

	dev-python/pytest[${PYTHON_USEDEP}]
	dev-python/sphinx[${PYTHON_USEDEP}]
	dev-python/numpydoc[${PYTHON_USEDEP}]

	dev-python/pyqt5[${PYTHON_USEDEP}]
	dev-python/fabio[${PYTHON_USEDEP}]
	dev-python/pyfai[${PYTHON_USEDEP}]
	sci-libs/pycifrw[${PYTHON_USEDEP}]
"
#	dev-python/PyQtWebEngine[${PYTHON_USEDEP}]
#sphinxcontrib-bibtex #dev
#sphinxcontrib-argdoc #dev

DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
"
#	dev-python/pyepics
#	dev-python/tomopy
#for EPICS pyepics, psycopg2, epicsscan

S="${WORKDIR}/${PN}-${PV}"

PATCHES=(
	"${FILESDIR}"/full_conf.patch
)
#	"${FILESDIR}"/py.patch

distutils_enable_sphinx docs
distutils_enable_tests pytest

python_compile() {
	INSTALL_DIR="${D}"
	distutils-r1_python_compile
	sed -i -e 's:../examples/:./examples/:' tests/*.py || die
	sed -i -e "s:'larch_scripts':'tests/larch_scripts':" tests/*.py || die
	sed -i -e "s:'test_larch_plugin':'tests/test_larch_plugin':" tests/*.py || die
	sed -i -e "s:'..', 'examples':'.', 'examples':" tests/*.py || die
}

python_compile_all() {
	esetup.py build
}

python_install_all() {
	mkdir "${D}"/bin
	distutils-r1_python_install_all
}
