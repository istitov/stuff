# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="Customizable lightweight SQL query tool for Beancount (BQL)"
HOMEPAGE="
	https://github.com/beancount/beanquery
	https://pypi.org/project/beanquery/
"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=app-office/beancount-2.3.4[${PYTHON_USEDEP}]
	>=dev-python/click-8.1[${PYTHON_USEDEP}]
	>=dev-python/python-dateutil-2.6.0[${PYTHON_USEDEP}]
	dev-python/tatsu-lts[${PYTHON_USEDEP}]
"

# Stock pytest only; no third-party plugins.
EPYTEST_PLUGINS=()

distutils_enable_tests pytest

python_prepare_all() {
	# Upstream's bare `find = {}` auto-discovery sweeps the top-level
	# docs/ tree into site-packages as a stray top-level package (the
	# PyPI wheel ships it the same way). Scope discovery to the library.
	grep -q '^find = {}$' pyproject.toml || die "package-discovery stanza moved"
	sed -i \
		-e 's/^\[tool\.setuptools\.packages\]$/[tool.setuptools.packages.find]/' \
		-e 's/^find = {}$/include = ["beanquery*"]/' \
		pyproject.toml || die
	distutils-r1_python_prepare_all
}
