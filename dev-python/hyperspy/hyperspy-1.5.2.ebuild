# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_5 python3_6 python3_7)

inherit distutils-r1 flag-o-matic

DESCRIPTION="Interactive analysis of multidimensional datasets tools"
HOMEPAGE="https://hyperspy.org/"
SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
#IUSE="mrcz tests"
IUSE="python doc +learning +gui-jupyter +speed +gui-traitsui"

RDEPEND="
	>=dev-python/numpy-1.10
	>=sci-libs/scipy-0.15
	dev-python/natsort
	>=dev-python/matplotlib-2.2.3
	!=dev-python/numpy-1.13.0
	>=dev-python/traits-4.5.0
	dev-python/requests
	>=dev-python/tqdm-0.4.9
	dev-python/sympy
	dev-python/dill
	>=dev-python/h5py-2.3
	>=dev-python/python-dateutil-2.5.0
	dev-python/ipyparallel
	>=dev-python/dask-0.18
	>=sci-libs/scikits_image-0.13
	>=dev-python/Pint-0.8
	dev-python/statsmodels
	dev-python/numexpr
	dev-python/sparse
	dev-python/imageio
	doc? ( >=app-misc/sphinx-1.7 dev-python/sphinx_rtd_theme )
	learning? ( sci-libs/scikits_learn )
	speed? ( dev-python/numba dev-python/cython )
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
