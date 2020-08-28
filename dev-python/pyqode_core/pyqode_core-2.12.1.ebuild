# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{6..9} )

inherit distutils-r1 flag-o-matic

MYPN="${PN/pyqode_core/pyqode.core}"
MYP="${MYPN}-${PV}"

DESCRIPTION="pyQode is a source code editor widget for PyQt/PySide"
HOMEPAGE="https://github.com/pyQode/pyQode"
SRC_URI="mirror://pypi/${P:0:1}/${MYPN}/${MYP}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="python doc test"

RDEPEND="
	dev-python/pygments[${PYTHON_USEDEP}]
	dev-python/future
	dev-python/pyqode_qt[${PYTHON_USEDEP}]
"
#    pyqode-uic? ( )
#    test? ('pytest-xdist', 'pytest-cov', 'pytest-pep8', 'pytest')

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
