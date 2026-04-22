# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python package to manipulate physical units"
HOMEPAGE="https://pint.readthedocs.io"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="numpy"

RDEPEND="
	>=dev-python/flexcache-0.3[${PYTHON_USEDEP}]
	>=dev-python/flexparser-0.4[${PYTHON_USEDEP}]
	>=dev-python/platformdirs-2.1.0[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.0.0[${PYTHON_USEDEP}]
	numpy? ( dev-python/numpy[${PYTHON_USEDEP}] )
"
DEPEND="${RDEPEND}"
