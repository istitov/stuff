# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{6,7} )

inherit distutils-r1 flag-o-matic

DESCRIPTION="Interactive analysis of multidimensional datasets tools"
HOMEPAGE="https://hyperspy.org/"
SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
#IUSE="mrcz tests"
IUSE="python doc +learning +gui-jupyter speed +gui-traitsui mrcz"

RDEPEND="
	>=dev-python/numpy-1.10[${PYTHON_USEDEP}]
	>=dev-python/scipy-0.15[${PYTHON_USEDEP}]
	dev-python/natsort[${PYTHON_USEDEP}]
	>=dev-python/matplotlib-2.2.3[${PYTHON_USEDEP}]
	!~dev-python/numpy-1.13.0
	>=dev-python/traits-4.5.0[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	>=dev-python/tqdm-0.4.9[${PYTHON_USEDEP}]
	dev-python/sympy[${PYTHON_USEDEP}]
	dev-python/dill[${PYTHON_USEDEP}]
	>=dev-python/h5py-2.3[${PYTHON_USEDEP}]
	dev-python/PTable[${PYTHON_USEDEP}]
	>=dev-python/python-dateutil-2.5.0[${PYTHON_USEDEP}]
	dev-python/ipyparallel[${PYTHON_USEDEP}]
	>=dev-python/dask-0.18[${PYTHON_USEDEP}]
	>=sci-libs/scikits_image-0.13[${PYTHON_USEDEP}]
	>=dev-python/Pint-0.8[${PYTHON_USEDEP}]
	dev-python/statsmodels[${PYTHON_USEDEP}]
	dev-python/numexpr[${PYTHON_USEDEP}]
	dev-python/sparse[${PYTHON_USEDEP}]
	dev-python/imageio[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	doc? ( >=app-misc/sphinx-1.7 dev-python/sphinx_rtd_theme )
	learning? ( sci-libs/scikits_learn[${PYTHON_USEDEP}] )
	speed? ( dev-python/numba[${PYTHON_USEDEP}] dev-python/cython[${PYTHON_USEDEP}] )
"
	##tests? ( >=dev-python/pytest-3.6 dev-python/pytest-mpl >=dev-python/matplotlib-3.1 )
	##mrcz? ( >=dev-python/blosc-1.5 >=dev-python/mrcz-0.3.6 )

DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
"

PDEPEND="
	gui-jupyter? ( >=dev-python/hyperspy-gui-ipywidgets-1.1.0 )
	gui-traitsui? ( >=dev-python/hyperspy-gui-traitsui-1.1.0 )
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
