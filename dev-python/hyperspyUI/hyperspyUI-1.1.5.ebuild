# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..12} )

inherit distutils-r1 flag-o-matic virtualx

DESCRIPTION="Provides graphic user interface (GUI) for hyperspy"
HOMEPAGE="http://hyperspy.org/hyperspyUI/"
SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="python doc test"

RDEPEND="
	>=dev-python/hyperspy-1.6.1[${PYTHON_USEDEP}]
	>=dev-python/hyperspy-gui-traitsui-1.3.1[${PYTHON_USEDEP}]
	>=dev-python/traitsui-5.2.0[${PYTHON_USEDEP}]
	>=dev-python/pyface-6.0.0[${PYTHON_USEDEP}]
	>=dev-python/matplotlib-3.0.3[${PYTHON_USEDEP}]
	dev-python/traits[${PYTHON_USEDEP}]
	dev-python/QtPy[${PYTHON_USEDEP}]
	>=dev-python/PyQt5-5.15.6[${PYTHON_USEDEP},widgets]
	dev-python/qtconsole[${PYTHON_USEDEP}]
	dev-python/autopep8[${PYTHON_USEDEP}]
	dev-python/PyQtWebEngine[${PYTHON_USEDEP}]
	dev-python/ipykernel[${PYTHON_USEDEP}]
	dev-qt/qtwebengine
	dev-python/importlib-resources
"
#dev-python/pyqode_python[${PYTHON_USEDEP}]

DEPEND="${RDEPEND}
	test? ( dev-python/pytest-qt[${PYTHON_USEDEP}] dev-python/pytest-cov[${PYTHON_USEDEP}] )
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
	virtx epytest
}

python_install_all() {
	distutils-r1_python_install_all
}
