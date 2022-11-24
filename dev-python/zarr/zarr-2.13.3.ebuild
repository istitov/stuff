# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7..10} )

inherit distutils-r1 flag-o-matic

DESCRIPTION="An implementation of chunked, compressed, N-dimensional arrays for Python"
HOMEPAGE="https://github.com/zarr-developers/zarr-python"
SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc python"

RDEPEND="
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/numcodecs[${PYTHON_USEDEP}]
"
#asciitree==0.3.3
#fasteners==0.18
#numcodecs==0.10.2
#msgpack-python==0.5.6
#setuptools-scm==7.0.5
#numpy==1.23.3

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
