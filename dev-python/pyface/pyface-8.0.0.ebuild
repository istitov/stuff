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
KEYWORDS="~amd64 ~x86"
IUSE="+wx +pyqt6 +pyside"

# importlib-metadata / importlib-resources are upstream conditional
# deps for python_version<3.10 / <3.9 respectively; PYTHON_COMPAT here
# is 3.12+, so they're not needed.
# Upstream lists numpy under the [numpy] optional-extra, but pyface
# imports it directly (e.g. pyface/data_view/abstract_value_type.py),
# so keep it unconditional.
RDEPEND="
	dev-python/numpy[${PYTHON_USEDEP}]
	>=dev-python/traits-6.2[${PYTHON_USEDEP}]
	pyqt6? ( dev-python/pyqt6[${PYTHON_USEDEP}] dev-python/pygments[${PYTHON_USEDEP}] )
	wx? ( >=dev-python/wxpython-2.8.10:*[${PYTHON_USEDEP}] )
	pyside? ( dev-python/pyside[${PYTHON_USEDEP}] dev-python/pygments[${PYTHON_USEDEP}] )
"
