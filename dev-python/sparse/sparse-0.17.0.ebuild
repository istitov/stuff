# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 pypi

DESCRIPTION="Sparse multi-dimensional arrays for the PyData ecosystem"
HOMEPAGE="https://github.com/pydata/sparse/"
#SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"
SRC_URI="$(pypi_sdist_url "${PN^}" "${PV}")"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

# Upstream [project].dependencies lists numpy>=1.17 and numba>=0.49
# only, but the source imports scipy.sparse / scipy.sparse.csgraph
# directly (verified 2026-04-29), so scipy stays in RDEPEND.
RDEPEND="
	>=dev-python/numpy-1.17[${PYTHON_USEDEP}]
	>=dev-python/numba-0.49[${PYTHON_USEDEP}]
	dev-python/scipy[${PYTHON_USEDEP}]
"
