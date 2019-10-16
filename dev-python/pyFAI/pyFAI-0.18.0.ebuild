# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_5 python3_6 python3_7)

inherit distutils-r1 flag-o-matic

DESCRIPTION="PyFAI is a python libary for azimuthal integration of diffraction data acquired with 2D detectors"
HOMEPAGE="https://pyfai.readthedocs.io"
SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="doc python"

RDEPEND="
	dev-python/cython
	dev-python/h5py
	dev-python/PyQt5
	dev-python/matplotlib
	dev-python/fabio
	dev-python/numpy
	sci-libs/scipy
	dev-python/pyopencl
	dev-python/silx
	dev-python/numexpr
	sci-libs/fftw
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