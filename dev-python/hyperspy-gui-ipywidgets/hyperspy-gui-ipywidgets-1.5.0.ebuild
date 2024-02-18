# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..12} )

inherit distutils-r1 flag-o-matic virtualx pypi

MYPN="${PN/hyperspy-gui-ipywidgets/hyperspy_gui_ipywidgets}"
MYP="${MYPN}-${PV}"

DESCRIPTION="Interactive analysis of multidimensional datasets tools"
HOMEPAGE="https://hyperspy.org/"
#SRC_URI="mirror://pypi/${P:0:1}/${MYPN}/${MYP}.tar.gz"
SRC_URI="$(pypi_sdist_url "${MYPN^}" "${PV}")"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="python doc"

RDEPEND="
	>=dev-python/hyperspy-1.5[${PYTHON_USEDEP}]
	>=dev-python/ipywidgets-6.0[${PYTHON_USEDEP}]
	dev-python/link-traits[${PYTHON_USEDEP}]
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
	virtx epytest
}

python_install_all() {
	distutils-r1_python_install_all
}
