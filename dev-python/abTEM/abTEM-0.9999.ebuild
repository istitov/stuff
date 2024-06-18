# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
#PYPI_NO_NORMALIZE=0
PYPI_PN="abtem"
#DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{9..12} )

inherit distutils-r1 git-r3

DESCRIPTION="ab initio transmission electron microscopy"
HOMEPAGE="https://github.com/abTEM/abTEM"
EGIT_REPO_URI="https://github.com/abTEM/abTEM-legacy"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="python"

RDEPEND="
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/scipy[${PYTHON_USEDEP}]
	dev-python/matplotlib[${PYTHON_USEDEP}]
	dev-python/numba[${PYTHON_USEDEP}]
	>=dev-python/dask-2022.12.1[${PYTHON_USEDEP}]
	dev-python/zarr[${PYTHON_USEDEP}]
	dev-python/ipympl[${PYTHON_USEDEP}]
	dev-python/ipywidgets[${PYTHON_USEDEP}]
	dev-python/jupyterlab[${PYTHON_USEDEP}]
	dev-python/jupyterlab-widgets[${PYTHON_USEDEP}]
	dev-python/ase[${PYTHON_USEDEP}]
	dev-python/pillow[${PYTHON_USEDEP}]
	dev-python/pandas[${PYTHON_USEDEP}]
	dev-python/bokeh[${PYTHON_USEDEP}]
	dev-python/distributed[${PYTHON_USEDEP}]
	dev-python/dask-labextension[${PYTHON_USEDEP}]
	dev-python/pyFFTW[${PYTHON_USEDEP}]
"

DEPEND="${RDEPEND}
"

src_prepare(){
	default
	mv test abtem/
}
