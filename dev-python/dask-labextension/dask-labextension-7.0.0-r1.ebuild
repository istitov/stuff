# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYPI_PN=${PN/-/_}
PYPI_NO_NORMALIZE=0
DISTUTILS_USE_PEP517=hatchling
# Tracks dev-python/jupyter-server-proxy, which is py3_{12..13} only
# in ::gentoo at the moment.
PYTHON_COMPAT=( python3_{12..13} )

inherit distutils-r1 pypi

DESCRIPTION="JupyterLab extension for Dask"
HOMEPAGE="https://github.com/dask/dask-labextension"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
# Upstream's test suite spins up a live JupyterLab instance and
# talks to it over HTTP; not runnable at package build time.
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
# distutils-r1 contributes only gpep517 and hatchling from
# DISTUTILS_USE_PEP517. Upstream's build-system.requires also names
# jupyterlab and hatch-nodejs-version, and the jupyter-builder build hook
# pulls hatch-jupyter-builder; without them the PEP 517 backend cannot load.
# The hook's npm step does not run: its ensured-targets, labextension/
# package.json and static/style.js, are both prebuilt in the sdist, so no
# nodejs is needed. verified 2026-07-27
BDEPEND="
	>=dev-python/hatch-jupyter-builder-0.5[${PYTHON_USEDEP}]
	dev-python/hatch-nodejs-version[${PYTHON_USEDEP}]
	>=dev-python/jupyterlab-4.0.0[${PYTHON_USEDEP}]
	<dev-python/jupyterlab-5.0.0[${PYTHON_USEDEP}]
"

python_install_all() {
	distutils-r1_python_install_all

	# Upstream's hatchling build hardcodes the Jupyter config drop
	# at /usr/etc/jupyter; move to the FHS-correct /etc/jupyter.
	if [[ -d ${ED}/usr/etc ]]; then
		mv "${ED}/usr/etc" "${ED}/etc" || die
	fi
}
