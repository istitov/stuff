# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 git-r3

DESCRIPTION="Processing and analysis of 4D-STEM data"
HOMEPAGE="https://github.com/py4dstem/py4DSTEM/"
EGIT_REPO_URI="https://github.com/py4dstem/py4DSTEM.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
# Upstream's test fixtures are large datasets pulled from Google
# Drive at test-time; not runnable at package build time.
RESTRICT="test"

# HEAD (post-0.14.18) has unpinned numpy, ncempy, and scikit-learn
# relative to the release, and added pymatgen as a mandatory dep.
# Match that; no patches needed here since the numpy-2 api fixes
# have been merged.
RDEPEND="
	>=dev-python/colorspacious-1.1.2[${PYTHON_USEDEP}]
	>=dev-python/dask-2.3.0[${PYTHON_USEDEP}]
	>=dev-python/dill-0.3.3[${PYTHON_USEDEP}]
	>=dev-python/distributed-2.3.0[${PYTHON_USEDEP}]
	>=dev-python/emdfile-0.0.14[${PYTHON_USEDEP}]
	>=dev-python/gdown-5.1.0[${PYTHON_USEDEP}]
	>=dev-python/h5py-3.2.0[${PYTHON_USEDEP}]
	>=dev-python/hdf5plugin-4.1.3[${PYTHON_USEDEP}]
	>=dev-python/matplotlib-3.2.2[${PYTHON_USEDEP}]
	>=dev-python/mpire-2.7.1[${PYTHON_USEDEP}]
	>=dev-python/ncempy-1.8.1[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.19[${PYTHON_USEDEP}]
	>=dev-python/pylops-2.1.0[${PYTHON_USEDEP}]
	>=dev-python/pymatgen-2022.11.7[${PYTHON_USEDEP}]
	>=dev-python/scikit-image-0.17.2[${PYTHON_USEDEP}]
	>=dev-python/scikit-learn-0.23.2[${PYTHON_USEDEP}]
	>=dev-python/scikit-optimize-0.9.0[${PYTHON_USEDEP}]
	>=dev-python/scipy-1.5.2[${PYTHON_USEDEP}]
	>=dev-python/threadpoolctl-3.1.0[${PYTHON_USEDEP}]
	>=dev-python/tqdm-4.46.1[${PYTHON_USEDEP}]
"
