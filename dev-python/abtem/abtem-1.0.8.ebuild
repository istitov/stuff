# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi virtualx

DESCRIPTION="ab initio transmission electron microscopy"
HOMEPAGE="
	https://github.com/abTEM/abTEM/
	https://pypi.org/project/abtem/
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-python/ase[${PYTHON_USEDEP}]
	>=dev-python/dask-2022.12.1[${PYTHON_USEDEP}]
	dev-python/distributed[${PYTHON_USEDEP}]
	dev-python/ipympl[${PYTHON_USEDEP}]
	dev-python/ipywidgets[${PYTHON_USEDEP}]
	>=dev-python/matplotlib-3.6[${PYTHON_USEDEP}]
	dev-python/numba[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/pandas[${PYTHON_USEDEP}]
	dev-python/pyfftw[${PYTHON_USEDEP}]
	dev-python/scipy[${PYTHON_USEDEP}]
	dev-python/tabulate[${PYTHON_USEDEP}]
	dev-python/threadpoolctl[${PYTHON_USEDEP}]
	dev-python/tqdm[${PYTHON_USEDEP}]
	dev-python/zarr[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}
	test? (
		dev-python/deepdiff[${PYTHON_USEDEP}]
		dev-python/hypothesis[${PYTHON_USEDEP}]
		dev-python/imageio[${PYTHON_USEDEP}]
		dev-python/jupyter-client[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_test() {
	virtx epytest
}
