# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

# Legacy sdist keeps the mixed-case "pyNSID-" filename PyPI no longer
# normalizes, so skip the eclass name normalization.
PYPI_NO_NORMALIZE=1

inherit distutils-r1 pypi

DESCRIPTION="Framework for N-dimensional Spectroscopic and Imaging Data (NSID) in HDF5"
HOMEPAGE="
	https://github.com/pycroscopy/pyNSID
	https://pycroscopy.github.io/pyNSID/
	https://pypi.org/project/pyNSID/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/numpy-1.10[${PYTHON_USEDEP}]
	dev-python/toolz[${PYTHON_USEDEP}]
	dev-python/cytoolz[${PYTHON_USEDEP}]
	dev-python/dask[${PYTHON_USEDEP}]
	>=dev-python/h5py-2.6.0[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]
	dev-python/ase[${PYTHON_USEDEP}]
	>=dev-python/sidpy-0.0.2[${PYTHON_USEDEP}]
"

# Upstream excludes the test suite from the sdist; nothing to run here.
