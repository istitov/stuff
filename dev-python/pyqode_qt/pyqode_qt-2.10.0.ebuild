# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{6..9} )

inherit distutils-r1 flag-o-matic

MYPN="${PN/pyqode_qt/pyqode.qt}"
MYP="${MYPN}-${PV}"

DESCRIPTION="Shim that let you write applications that supports both PyQt and PySide"
HOMEPAGE="https://github.com/pyQode/pyqode.qt"
SRC_URI="mirror://pypi/${P:0:1}/${MYPN}/${MYP}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="python doc"

RDEPEND="
	dev-python/PyQt5[${PYTHON_USEDEP}]
"
#        You need *PyQt5* or *PyQt4* or *PySide* installed on your system to make use
#       of pyqode.qt, obviously.

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
