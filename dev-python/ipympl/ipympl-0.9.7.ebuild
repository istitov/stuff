# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{9..11} )

inherit distutils-r1 pypi

DESCRIPTION="Matplotlib Jupyter Extension"
SRC_URI="$(pypi_sdist_url "${PN^}" "${PV}")"
HOMEPAGE="http://matplotlib.org"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

IUSE=""
RDEPEND=">=dev-python/ipykernel-4.7[${PYTHON_USEDEP}]
	>=dev-python/ipywidgets-7.6.0[${PYTHON_USEDEP}]
	>=dev-python/matplotlib-2.0.0[${PYTHON_USEDEP}]"
distutils_enable_tests pytest
