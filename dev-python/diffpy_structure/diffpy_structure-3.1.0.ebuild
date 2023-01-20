# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{6..10} )

inherit distutils-r1 flag-o-matic

MYPN="${PN/diffpy_structure/diffpy.structure}"
MYP="${MYPN}-${PV}"

DESCRIPTION="Crystal structure container and parsers for structure formats"
HOMEPAGE="https://github.com/diffpy/diffpy.structure"
SRC_URI="mirror://pypi/${MYP:0:1}/${MYPN}/${MYP}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc python"

RDEPEND="
	>=dev-python/numpy-1.5.1[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
"

DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

S="${WORKDIR}/${MYP}"

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
