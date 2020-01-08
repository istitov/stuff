Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_5 python3_6 )

inherit distutils-r1 flag-o-matic

DESCRIPTION="Python wrappers for generating CTest and submitting to CDash without a CMake"
HOMEPAGE="https://github.com/jrmadsen/pyctest"
SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc python"

RDEPEND="

"

DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
"

#The C++ compiler requires support for C++11, in particular it needs to support lambdas and std::unique_ptr

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
