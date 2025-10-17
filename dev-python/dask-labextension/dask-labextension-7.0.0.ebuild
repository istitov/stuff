# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYPI_PN=${PN/-/_}
PYPI_NO_NORMALIZE=0
DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{8..11} )

inherit distutils-r1 pypi

DESCRIPTION="JupyterLab extension for Dask"
HOMEPAGE="https://github.com/dask/dask-labextension"

LICENSE="BSD-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="python"

RDEPEND="
	dev-python/distributed[${PYTHON_USEDEP}]
	dev-python/dask[${PYTHON_USEDEP}]
	>=dev-python/jupyter-server-proxy-1.3.2[${PYTHON_USEDEP}] 
	<dev-python/jupyterlab-5.0.0[${PYTHON_USEDEP}]
	>=dev-python/jupyterlab-4.0.0[${PYTHON_USEDEP}]
	!=dev-python/bokeh-2.0.0[${PYTHON_USEDEP}]
	>=dev-python/bokeh-1.0.0[${PYTHON_USEDEP}]
"

DEPEND="${RDEPEND}
"
