# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python package to manipulate physical units"
HOMEPAGE="https://pint.readthedocs.io"
SRC_URI="$(pypi_sdist_url --no-normalize "${PN^}" "${PV}")"
S=${WORKDIR}/${P^}

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

PATCHES=(
	"${FILESDIR}/${P}-numpy-2.4.patch"
	"${FILESDIR}/${P}-python-3.13.patch"
)

IUSE="numpy"

RDEPEND="
	dev-python/typing-extensions[${PYTHON_USEDEP}]
	numpy? ( dev-python/numpy[${PYTHON_USEDEP}] )
"

EPYTEST_PLUGINS=()
EPYTEST_IGNORE=( pint/testsuite/test_babel.py )
EPYTEST_DESELECT=( pint/testsuite/test_dask.py::test_async )
distutils_enable_tests pytest
