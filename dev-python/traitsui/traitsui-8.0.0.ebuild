# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 pypi

DESCRIPTION="Toolkit-independent GUI abstraction layer for visualization features of Traits"
HOMEPAGE="https://docs.enthought.com/traitsui/"
#SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"
SRC_URI="$(pypi_sdist_url "${PN^}" "${PV}")"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+wx +pyqt6 +pyside +demo"

RDEPEND="
	>=dev-python/traits-6.2[${PYTHON_USEDEP}]
	>=dev-python/pyface-8.0[${PYTHON_USEDEP},wx=,pyqt6=,pyside=]
	wx? ( >=dev-python/wxpython-2.8.10:*[${PYTHON_USEDEP}] dev-python/numpy[${PYTHON_USEDEP}] )
	pyqt6? ( dev-python/pyqt6[${PYTHON_USEDEP}] dev-python/pygments[${PYTHON_USEDEP}] )
	pyside? ( dev-python/pyside[${PYTHON_USEDEP}] dev-python/pygments[${PYTHON_USEDEP}] )
	demo? ( dev-python/configobj[${PYTHON_USEDEP}] )
"
