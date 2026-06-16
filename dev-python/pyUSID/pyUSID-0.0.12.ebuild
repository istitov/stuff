# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

# Legacy sdist keeps the mixed-case "pyUSID-" filename PyPI no longer
# normalizes, so skip the eclass name normalization.
PYPI_NO_NORMALIZE=1

inherit distutils-r1 pypi

DESCRIPTION="Framework for Universal Spectroscopic and Imaging Data (USID) in HDF5"
HOMEPAGE="
	https://github.com/pycroscopy/pyUSID
	https://pycroscopy.github.io/pyUSID/
	https://pypi.org/project/pyUSID/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/numpy-1.20[${PYTHON_USEDEP}]
	dev-python/toolz[${PYTHON_USEDEP}]
	dev-python/cytoolz[${PYTHON_USEDEP}]
	dev-python/dask[${PYTHON_USEDEP}]
	>=dev-python/h5py-2.6.0[${PYTHON_USEDEP}]
	dev-python/pillow[${PYTHON_USEDEP}]
	dev-python/psutil[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]
	>=dev-python/sidpy-0.10[${PYTHON_USEDEP}]
"

# Upstream excludes the test suite from the sdist; nothing to run here.
