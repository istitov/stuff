# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Sparse multi-dimensional arrays for the PyData ecosystem"
HOMEPAGE="
	https://github.com/pydata/sparse
	https://pypi.org/project/sparse/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/numpy-1.17[${PYTHON_USEDEP}]
	>=dev-python/numba-0.49[${PYTHON_USEDEP}]
"
BDEPEND="dev-python/setuptools-scm[${PYTHON_USEDEP}]"

# setuptools_scm cannot derive a version from the gitless sdist.
export SETUPTOOLS_SCM_PRETEND_VERSION="${PV}"

# Test suite is a heavy numba/hypothesis matrix; upstream-tested.
RESTRICT="test"
