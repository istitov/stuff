# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 pypi

DESCRIPTION="Linear operators to allow solving large-scale optimization problems"
HOMEPAGE="https://github.com/PyLops/pylops"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="advanced"

RDEPEND="
	>=dev-python/numpy-1.21.0[${PYTHON_USEDEP}]
	>=dev-python/scipy-1.11.0[${PYTHON_USEDEP}]
	advanced? (
		dev-python/llvmlite[${PYTHON_USEDEP}]
		dev-python/numba[${PYTHON_USEDEP}]
		dev-python/pyfftw[${PYTHON_USEDEP}]
		dev-python/pywavelets[${PYTHON_USEDEP}]
	)
"
DEPEND="${RDEPEND}"
