# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

#PYPI_NO_NORMALIZE=0
PYPI_PN="abtem"
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 git-r3 virtualx

DESCRIPTION="ab initio transmission electron microscopy"
HOMEPAGE="https://github.com/abTEM/abTEM"
EGIT_REPO_URI="https://github.com/abTEM/abTEM"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""

RDEPEND="
	dev-python/ase[${PYTHON_USEDEP}]
	>=dev-python/dask-2022.12.1[${PYTHON_USEDEP}]
	dev-python/distributed[${PYTHON_USEDEP}]
	dev-python/ipympl[${PYTHON_USEDEP}]
	dev-python/ipywidgets[${PYTHON_USEDEP}]
	>=dev-python/matplotlib-3.6[${PYTHON_USEDEP}]
	dev-python/numba[${PYTHON_USEDEP}]
	>=dev-python/numpy-2.0.0[${PYTHON_USEDEP}]
	dev-python/pandas[${PYTHON_USEDEP}]
	dev-python/pyfftw[${PYTHON_USEDEP}]
	dev-python/rich[${PYTHON_USEDEP}]
	dev-python/scipy[${PYTHON_USEDEP}]
	dev-python/tabulate[${PYTHON_USEDEP}]
	dev-python/threadpoolctl[${PYTHON_USEDEP}]
	dev-python/tqdm[${PYTHON_USEDEP}]
	dev-python/zarr[${PYTHON_USEDEP}]
"

DEPEND="${RDEPEND}
"

python_test() {
	virtx epytest
}
