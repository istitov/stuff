# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{9..12} )

inherit distutils-r1 flag-o-matic

DESCRIPTION="Set of Python modules for atomistic simulations"
HOMEPAGE="http://wiki.fysik.dtu.dk/ase"
SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc examples test"
PYTHON_REQ_USE="tk"

RDEPEND="${PYTHON_DEPS}
	dev-python/numpy
	dev-python/scipy
	dev-python/matplotlib
	dev-python/psycopg
	"
#psycopg2-binary
DEPEND="dev-python/setuptools"

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
