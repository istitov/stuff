# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 pypi

DESCRIPTION="Toolkit-independent GUI abstraction layer for visualization features of Traits"
HOMEPAGE="https://docs.enthought.com/pyface/"
SRC_URI="$(pypi_sdist_url "${PN}" "${PV}")"
S=${WORKDIR}/${P}

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="wx +pyqt6 pyside"

# Python 3.12+ needs neither importlib backport. NumPy is optional upstream but
# imported unconditionally, so retain it.
RDEPEND="
	dev-python/numpy[${PYTHON_USEDEP}]
	>=dev-python/traits-6.2[${PYTHON_USEDEP}]
	pyqt6? ( dev-python/pyqt6[${PYTHON_USEDEP}] dev-python/pygments[${PYTHON_USEDEP}] )
	wx? ( >=dev-python/wxpython-4:*[${PYTHON_USEDEP}] )
	pyside? ( dev-python/pyside[${PYTHON_USEDEP}] dev-python/pygments[${PYTHON_USEDEP}] )
"
