# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 pypi

MYPN="${PN/hyperspy-gui-ipywidgets/hyperspy_gui_ipywidgets}"
MYP="${MYPN}-${PV}"

DESCRIPTION="Interactive analysis of multidimensional datasets tools"
HOMEPAGE="https://hyperspy.org/"
#SRC_URI="mirror://pypi/${P:0:1}/${MYPN}/${MYP}.tar.gz"
SRC_URI="$(pypi_sdist_url "${MYPN^}" "${PV}")"

S="${WORKDIR}/${MYP}"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="python doc"

RDEPEND="
	>=dev-python/hyperspy-2.0[${PYTHON_USEDEP}]
	>=dev-python/ipywidgets-6.0[${PYTHON_USEDEP}]
	dev-python/link-traits[${PYTHON_USEDEP}]
"

DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"
