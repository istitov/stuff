# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{6..10} )

inherit distutils-r1 flag-o-matic

MYPN="${PN/pyqode_python/pyqode.python}"
MYP="${MYPN}-${PV}"

DESCRIPTION="pyqode.python adds python support to pyQode (code completion, calltips, etc)"
HOMEPAGE="https://github.com/pyQode/pyqode.python"
SRC_URI="mirror://pypi/${P:0:1}/${MYPN}/${MYP}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="python doc pyqt-distutils pyqode-uic test"

RDEPEND="
	dev-python/traits[${PYTHON_USEDEP}]
	dev-python/docutils[${PYTHON_USEDEP}]
	dev-python/jedi[${PYTHON_USEDEP}]
	dev-python/pyflakes[${PYTHON_USEDEP}]
	dev-python/pycodestyle[${PYTHON_USEDEP}]
	dev-python/pyqode_qt[${PYTHON_USEDEP}]
	dev-python/pyqode_core[${PYTHON_USEDEP}]
	pyqt-distutils? ( dev-python/pyqt-distutils[${PYTHON_USEDEP}] )
"
#    pyqode-uic? ( )
#    test? ('pytest-cov', 'pytest-pep8', 'pytest')

DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

S="${WORKDIR}/${MYP}"

python_compile() {
	distutils-r1_python_compile

}

python_compile_all() {
	use doc && setup.py build
}

python_test() {
	setup.py test
}

python_install_all() {
	distutils-r1_python_install_all
}
