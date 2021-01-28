# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_7 )

inherit distutils-r1 flag-o-matic

DESCRIPTION="Python library for multi-dimensional diffraction microscopy"
HOMEPAGE="https://pyxem.github.io"
SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc python"

RDEPEND="
	sci-libs/scikit-image[${PYTHON_USEDEP}]
	sci-libs/scikit-learn[${PYTHON_USEDEP}]
	dev-python/matplotlib[${PYTHON_USEDEP}]
	dev-python/hyperspy[${PYTHON_USEDEP}]
	dev-python/lmfit[${PYTHON_USEDEP}]
	dev-python/diffsims[${PYTHON_USEDEP}]
	dev-python/pyFAI[${PYTHON_USEDEP}]
	dev-python/ipywidgets[${PYTHON_USEDEP}]
	dev-python/numba[${PYTHON_USEDEP}]
"
#	>=dev-python/matplotlib-3.1.1

DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
"

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
