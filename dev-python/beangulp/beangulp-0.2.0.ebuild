# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="Importers framework for Beancount"
HOMEPAGE="
	https://github.com/beancount/beangulp
	https://pypi.org/project/beangulp/
"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=app-office/beancount-2.3.5[${PYTHON_USEDEP}]
	dev-python/beautifulsoup4[${PYTHON_USEDEP}]
	dev-python/chardet[${PYTHON_USEDEP}]
	>=dev-python/click-8.1[${PYTHON_USEDEP}]
	dev-python/lxml[${PYTHON_USEDEP}]
	>=dev-python/python-magic-0.4.12[${PYTHON_USEDEP}]
"

# Suite uses only stock pytest + rst doctests (--doctest-glob, set in
# the upstream pyproject), no third-party plugins.
EPYTEST_PLUGINS=()

distutils_enable_tests pytest

python_prepare_all() {
	# Upstream's bare `find = {}` auto-discovery sweeps the top-level
	# examples/ and tools/ trees into site-packages as stray top-level
	# packages (the PyPI wheel does the same; pip tolerates it, the
	# eclass does not). Scope discovery to the library proper.
	grep -q '^find = {}$' pyproject.toml || die "package-discovery stanza moved"
	sed -i \
		-e 's/^\[tool\.setuptools\.packages\]$/[tool.setuptools.packages.find]/' \
		-e 's/^find = {}$/include = ["beangulp*"]/' \
		pyproject.toml || die
	distutils-r1_python_prepare_all
}
