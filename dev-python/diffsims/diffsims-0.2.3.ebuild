# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7} )

inherit distutils-r1 flag-o-matic

DESCRIPTION="Python library for simulating diffraction"
HOMEPAGE="https://github.com/pyxem/diffsims"
SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc python"

RDEPEND="
	>=dev-python/numpy-1.10[${PYTHON_USEDEP}]
	>=dev-python/scipy-0.15[${PYTHON_USEDEP}]
	dev-python/matplotlib[${PYTHON_USEDEP}]
	>=dev-python/tqdm-0.4.9[${PYTHON_USEDEP}]
	dev-python/numba[${PYTHON_USEDEP}]
	dev-python/diffpy_structure[${PYTHON_USEDEP}]
	dev-python/transforms3d[${PYTHON_USEDEP}]
	dev-python/psutil[${PYTHON_USEDEP}]
"
#	>=dev-python/matplotlib-3.1.1
#	

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
