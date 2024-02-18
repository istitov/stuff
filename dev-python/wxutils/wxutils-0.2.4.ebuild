# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..12} )

inherit distutils-r1 flag-o-matic

DESCRIPTION="A library of convenience functions for wxPython"
HOMEPAGE="https://github.com/newville/wxutils"
SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc python"

RDEPEND="
	dev-python/wxpython:*[${PYTHON_USEDEP}]
"
#dev-python/PyQt4

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
	#setup.py install
	distutils-r1_python_install_all
}
