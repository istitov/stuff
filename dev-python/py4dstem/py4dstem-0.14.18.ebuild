# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Processing and analysis of 4D-STEM data"
HOMEPAGE="
	https://github.com/py4dstem/py4DSTEM/
	https://pypi.org/project/py4dstem/
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
# Upstream's test fixtures are large datasets pulled from Google
# Drive at test-time; not runnable at package build time.
RESTRICT="test"

# 0.14.18's setup.py caps numpy<2, ncempy<=1.11.2 and scikit-learn<1.5.
# distutils-r1 with PEP 517 uses pip --no-deps at install time, so
# these caps don't block the build - but numpy 2 also tripped actual
# API uses in three source files (np.string_ -> np.bytes_, etc.).
# Carry upstream PR #712 to fix those (merged post-release on
# 2025-03-17). scikit-learn-1.5+ was similarly unpinned upstream on
# 2025-04-30 but has no accompanying source fixes, so runtime may
# still hit the occasional sklearn-sensitive code path. The ncempy
# upper bound is dropped here: 1.11.2 is no longer in the overlay and
# current ncempy (1.13+) keeps the io.read() surface py4dstem actually
# calls.
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
	>=dev-python/scikit-image-0.17.2[${PYTHON_USEDEP}]
	>=dev-python/scikit-learn-0.23.2[${PYTHON_USEDEP}]
	>=dev-python/scikit-optimize-0.9.0[${PYTHON_USEDEP}]
	>=dev-python/scipy-1.5.2[${PYTHON_USEDEP}]
	>=dev-python/threadpoolctl-3.1.0[${PYTHON_USEDEP}]
	>=dev-python/tqdm-4.46.1[${PYTHON_USEDEP}]
"

PATCHES=(
	"${FILESDIR}/${P}-numpy2-compat.patch"
)
