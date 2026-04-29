# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 pypi

MYPN="${PN/hyperspy-gui-traitsui/hyperspy_gui_traitsui}"
MYP="${MYPN}-${PV}"

DESCRIPTION="Provides traitsui graphic user interface (GUI) elements for hyperspy"
HOMEPAGE="https://hyperspy.org/"
#SRC_URI="mirror://pypi/${P:0:1}/${MYPN}/${MYP}.tar.gz"
SRC_URI="$(pypi_sdist_url "${MYPN^}" "${PV}")"

S="${WORKDIR}/${MYP}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/hyperspy-2.3.0[${PYTHON_USEDEP}]
	>=dev-python/traits-6.3[${PYTHON_USEDEP}]
	>=dev-python/traitsui-7.3[${PYTHON_USEDEP}]
"
