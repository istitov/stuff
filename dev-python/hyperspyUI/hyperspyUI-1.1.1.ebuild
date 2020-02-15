# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_5 python3_6 python3_7)

inherit distutils-r1 flag-o-matic

DESCRIPTION="Provides graphic user interface (GUI) for hyperspy"
HOMEPAGE="http://hyperspy.org/hyperspyUI/"
SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="python doc test"

RDEPEND="
	>=dev-python/hyperspy-1.4.1
	>=dev-python/hyperspy-gui-traitsui-1.1.1
	>=dev-python/traitsui-5.2.0
	>=dev-python/pyface-6.0.0
	>=dev-python/matplotlib-1.3
	dev-python/traits
	dev-python/QtPy
	dev-python/PyQt5[webkit]
	dev-python/qtconsole
	dev-python/autopep8
       	dev-python/pyqode_python
        test? ( dev-python/pytest-qt dev-python/pytest-cov )
"


DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

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
