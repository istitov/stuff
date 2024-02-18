# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..12} )

inherit distutils-r1 flag-o-matic

MYPN="${PN/hyperspy-gui-traitsui/hyperspy_gui_traitsui}"
MYP="${MYPN}-${PV}"

DESCRIPTION="Provides traitsui graphic user interface (GUI) elements for hyperspy"
HOMEPAGE="https://hyperspy.org/"
SRC_URI="mirror://pypi/${P:0:1}/${MYPN}/${MYP}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="python doc"

RDEPEND="
	>=dev-python/hyperspy-1.5[${PYTHON_USEDEP}]
	>=dev-python/traitsui-6.0[${PYTHON_USEDEP}]
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
