# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Data fitting with Bayesian uncertainty analysis"
HOMEPAGE="
	https://github.com/bumps/bumps
	https://pypi.org/project/bumps/
	https://bumps.readthedocs.io/
"

LICENSE="public-domain MIT BSD"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/scipy[${PYTHON_USEDEP}]
	dev-python/h5py[${PYTHON_USEDEP}]
	dev-python/dill[${PYTHON_USEDEP}]
	dev-python/cloudpickle[${PYTHON_USEDEP}]
	dev-python/matplotlib[${PYTHON_USEDEP}]
	dev-python/blinker[${PYTHON_USEDEP}]
	dev-python/aiohttp[${PYTHON_USEDEP}]
	dev-python/python-socketio[${PYTHON_USEDEP}]
	dev-python/plotly[${PYTHON_USEDEP}]
	dev-python/mpld3[${PYTHON_USEDEP}]
	dev-python/msgpack[${PYTHON_USEDEP}]
	dev-python/uncertainties[${PYTHON_USEDEP}]
"
EPYTEST_PLUGINS=()
distutils_enable_tests pytest

src_prepare() {
	# The sdist bakes bumps/_version.py with the final version string,
	# so versioningit is not needed at build time. Drop it from
	# build-system.requires to avoid pulling in a deprecated dep.
	sed -i -e 's/, *"versioningit"//' pyproject.toml || die
	distutils-r1_src_prepare
}
