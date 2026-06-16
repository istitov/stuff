# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python utilities for spectroscopic and imaging data (SID)"
HOMEPAGE="
	https://github.com/pycroscopy/sidpy
	https://pycroscopy.github.io/sidpy/
	https://pypi.org/project/sidpy/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/numpy-1.10[${PYTHON_USEDEP}]
	dev-python/toolz[${PYTHON_USEDEP}]
	dev-python/cytoolz[${PYTHON_USEDEP}]
	dev-python/dask[${PYTHON_USEDEP}]
	>=dev-python/dask-ml-2025.1.0[${PYTHON_USEDEP}]
	>=dev-python/h5py-2.6.0[${PYTHON_USEDEP}]
	>=dev-python/matplotlib-2.0.0[${PYTHON_USEDEP}]
	>=dev-python/distributed-2.0.0[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]
	>=dev-python/joblib-0.11.0[${PYTHON_USEDEP}]
	dev-python/ipywidgets[${PYTHON_USEDEP}]
	dev-python/ipykernel[${PYTHON_USEDEP}]
	dev-python/ipython[${PYTHON_USEDEP}]
	>=dev-python/scikit-learn-1.6.1[${PYTHON_USEDEP}]
	dev-python/scipy[${PYTHON_USEDEP}]
	dev-python/ase[${PYTHON_USEDEP}]
	dev-python/ipympl[${PYTHON_USEDEP}]
	dev-python/dill[${PYTHON_USEDEP}]
	>=dev-python/pyswarms-1.3.0[${PYTHON_USEDEP}]
"

# Test suite requires SciFiReaders (a downstream reverse-dep of sidpy)
# plus bundled HDF5 fixtures; circular and fragile out of tree.
RESTRICT="test"
