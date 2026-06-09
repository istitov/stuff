# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python library for handling crystal orientation mapping data"
HOMEPAGE="
	https://github.com/pyxem/orix
	https://pypi.org/project/orix/
"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"

# Tests pull pytest-rerunfailures, pytest-xdist and numpydoc just to
# run; build-time validation of the package layout is enough.
RESTRICT="test"

RDEPEND="
	dev-python/dask[${PYTHON_USEDEP}]
	>=dev-python/diffpy-structure-3.0.2[${PYTHON_USEDEP}]
	dev-python/h5py[${PYTHON_USEDEP}]
	dev-python/lazy-loader[${PYTHON_USEDEP}]
	>=dev-python/matplotlib-3.6.1[${PYTHON_USEDEP}]
	dev-python/numba[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	>=dev-python/pooch-0.13[${PYTHON_USEDEP}]
	sci-libs/pycifrw[${PYTHON_USEDEP}]
	dev-python/scipy[${PYTHON_USEDEP}]
	dev-python/tqdm[${PYTHON_USEDEP}]
"
