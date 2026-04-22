# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Matplotlib Jupyter Extension"
HOMEPAGE="http://matplotlib.org"
SRC_URI="$(pypi_sdist_url "${PN^}" "${PV}")"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/ipython[${PYTHON_USEDEP}]
	>=dev-python/ipywidgets-7.6.0[${PYTHON_USEDEP}]
	>=dev-python/matplotlib-3.5.0[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/pillow[${PYTHON_USEDEP}]
	<dev-python/traitlets-6[${PYTHON_USEDEP}]
"
EPYTEST_PLUGINS=()
distutils_enable_tests pytest

src_prepare() {
	# The JS/TypeScript lab extension is built separately (in a separate
	# ipympl-jupyterlab package). Strip the hatch jupyter-builder hook so
	# the Python wheel does not try to `jlpm install` from npm at build time.
	sed -i '/^\[tool\.hatch\.build\.hooks\.jupyter-builder/,/^\[/{/^\[tool\.hatch\.build\.hooks\.jupyter-builder/d;/^\[/!d}' \
		pyproject.toml || die
	distutils-r1_src_prepare
}
