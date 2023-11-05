# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{7..12} )

inherit distutils-r1 flag-o-matic pypi

DESCRIPTION="Toolkit-independent GUI abstraction layer for visualization features of Traits"
HOMEPAGE="https://docs.enthought.com/pyface/"
SRC_URI="$(pypi_sdist_url "${PN}" "${PV}")"
S=${WORKDIR}/${P}

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="python doc +wx +pyqt5 +pyside"

RDEPEND="
	dev-python/traits[${PYTHON_USEDEP}]
	>=dev-python/importlib-metadata-3.6[${PYTHON_USEDEP}]
	pyqt5? ( dev-python/PyQt5[${PYTHON_USEDEP}] dev-python/pygments[${PYTHON_USEDEP}] )
	wx? ( >=dev-python/wxpython-2.8.10:*[${PYTHON_USEDEP}] dev-python/numpy[${PYTHON_USEDEP}] )
	pyside? ( dev-python/pyside2[${PYTHON_USEDEP}] dev-python/pygments[${PYTHON_USEDEP}] )
"
#	dev-python/importlib-resources
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
