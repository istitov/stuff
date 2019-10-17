# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_5 python3_6 python3_7)

inherit distutils-r1 flag-o-matic

DESCRIPTION="HyperSpy provides tools for the interactive analysis of multidimensional datasets"
HOMEPAGE="https://hyperspy.org/"
SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="learning gui-jupyter python gui-traitsui mrcz speed tests doc"

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
	learning? ( sci-libs/scikits_learn )
	speed? ( dev-python/numba dev-python/cython )
	doc? ( >=app-misc/sphinx-1.7 dev-python/sphinx_rtd_theme )
"
	#tests? ( >=dev-python/pytest-3.6 dev-python/pytest-mpl >=dev-python/matplotlib-3.1 )
	#mrcz? ( >=dev-python/blosc-1.5 >=dev-python/mrcz-0.3.6 )
	#gui-jupyter? ( >=hyperspy_gui_ipywidgets-1.1.0 )
	#gui-traitsui? ( >=hyperspy_gui_traitsui-1.1.0 )

#dev-python/PyQt4

DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

python_compile() {
	distutils-r1_python_compile
# \
#		$(use_enable learning) \
#		$(use_enable gui-jupyter) \
#		$(use_enable gui-traitsui) \
#		$(use_enable mrcz) \
#		$(use_enable speed)
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
