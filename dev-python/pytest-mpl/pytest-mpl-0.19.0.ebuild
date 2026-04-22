# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Pytest plugin to faciliate image comparison for matplotlib figures"
HOMEPAGE="https://github.com/matplotlib/pytest-mpl"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="examples"
RESTRICT="test"	# Test phase runs with fails

RDEPEND="
	>=dev-python/pytest-6.2.5[${PYTHON_USEDEP}]
	>=dev-python/matplotlib-3.5.3[${PYTHON_USEDEP}]
	>=dev-python/packaging-22.0.0[${PYTHON_USEDEP}]
	>=dev-python/jinja2-2.10.2[${PYTHON_USEDEP}]
	>=dev-python/pillow-8.1.1[${PYTHON_USEDEP}]
"

DOCS=( CHANGES.md README.rst )

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_install_all() {
	use examples && DOCS+=( images/ )
	distutils-r1_python_install_all
}
