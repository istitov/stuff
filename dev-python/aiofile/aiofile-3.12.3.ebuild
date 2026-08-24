# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Asynchronous file operations for Python"
HOMEPAGE="https://pypi.org/project/aiofile/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/caio-0.12.0[${PYTHON_USEDEP}]
	<dev-python/caio-0.13[${PYTHON_USEDEP}]
"

# The upstream suite requires unpackaged test-only plugins.
RESTRICT="test"
