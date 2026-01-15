# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{9..14} )

inherit distutils-r1 pypi

DESCRIPTION="Matplotlib Jupyter Extension"
HOMEPAGE="http://matplotlib.org"
SRC_URI="$(pypi_sdist_url "${PN^}" "${PV}")"

LICENSE="BSD"
SLOT="0"
KEYWORDS=""

RDEPEND=">=dev-python/ipykernel-4.7[${PYTHON_USEDEP}]
	>=dev-python/ipywidgets-7.6.0[${PYTHON_USEDEP}]
	>=dev-python/matplotlib-2.0.0[${PYTHON_USEDEP}]"
distutils_enable_tests pytest
