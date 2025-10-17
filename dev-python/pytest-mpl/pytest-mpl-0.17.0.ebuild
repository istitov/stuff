# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{9..12} )

inherit distutils-r1

DESCRIPTION="Pytest plugin to faciliate image comparison for matplotlib figures"
HOMEPAGE="https://github.com/matplotlib/pytest-mpl"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="examples"
RESTRICT="test"	# Test phase runs with fails

RDEPEND="dev-python/pytest[${PYTHON_USEDEP}]
	dev-python/jinja[${PYTHON_USEDEP}]
	dev-python/matplotlib[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/importlib_resources[${PYTHON_USEDEP}]
	' python3_8)
"

DOCS=( CHANGES.md README.rst )

distutils_enable_tests pytest

python_install_all() {
	use examples && DOCS+=( images/ )
	distutils-r1_python_install_all
}
