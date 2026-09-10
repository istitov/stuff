# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYPI_PN=${PN/-/_}
PYPI_NO_NORMALIZE=0
DISTUTILS_USE_PEP517=hatchling
# Match jupyter-server-proxy's Python targets.
PYTHON_COMPAT=( python3_{12..13} )

inherit distutils-r1 pypi

DESCRIPTION="JupyterLab extension for Dask"
HOMEPAGE="https://github.com/dask/dask-labextension"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
# Tests start JupyterLab and communicate over HTTP.
RESTRICT="test"

RDEPEND="
	dev-python/dask[${PYTHON_USEDEP}]
	>=dev-python/distributed-1.24.1[${PYTHON_USEDEP}]
	>=dev-python/jupyter-server-proxy-1.3.2[${PYTHON_USEDEP}]
	>=dev-python/jupyterlab-4.0.0[${PYTHON_USEDEP}]
	<dev-python/jupyterlab-5.0.0[${PYTHON_USEDEP}]
	>=dev-python/bokeh-1.0.0[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
# Add the build hook's undeclared backend dependencies. Its npm targets are
# prebuilt in the sdist, so Node is unnecessary. verified 2026-07-27
BDEPEND="
	>=dev-python/hatch-jupyter-builder-0.5[${PYTHON_USEDEP}]
	dev-python/hatch-nodejs-version[${PYTHON_USEDEP}]
	>=dev-python/jupyterlab-4.0.0[${PYTHON_USEDEP}]
	<dev-python/jupyterlab-5.0.0[${PYTHON_USEDEP}]
"

python_install_all() {
	distutils-r1_python_install_all

	# Move the hardcoded config path from /usr/etc to /etc.
	if [[ -d ${ED}/usr/etc ]]; then
		mv "${ED}/usr/etc" "${ED}/etc" || die
	fi
}
