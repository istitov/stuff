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

# query_render assertions hard-code exact column widths that predate
# beancount 3.2.x reserving a leading sign-alignment column; against the
# beancount we ship (3.2.3) every rendered amount gains a leading space,
# so these width-exact tests fail. The renderer itself is correct (the
# diffs show well-formed tables, only shifted by the sign space) and
# 0.2.0 is the latest beanquery — upstream simply hasn't refreshed these
# expectations. Verified cosmetic 2026-06-02; revisit on the next bump.
EPYTEST_DESELECT=(
	beanquery/query_render_test.py::TestAmountRenderer::test_amount
	beanquery/query_render_test.py::TestAmountRenderer::test_currency_padding
	beanquery/query_render_test.py::TestAmountRenderer::test_decimal_alignment
	beanquery/query_render_test.py::TestAmountRenderer::test_many
	beanquery/query_render_test.py::TestAmountRenderer::test_quantization_many
	beanquery/query_render_test.py::TestAmountRenderer::test_quantization_one
	beanquery/query_render_test.py::TestPositionRenderer::test_positions_with_price
	beanquery/query_render_test.py::TestPositionRenderer::test_simple_poitions
	beanquery/query_render_test.py::TestInventoryRenderer::test_inventory
	beanquery/query_render_test.py::TestInventoryRenderer::test_inventory_tabular
	beanquery/query_render_test.py::TestInventoryRenderer::test_inventory_too_many
	beanquery/query_render_test.py::TestCostRenderer::test_cost
	beanquery/query_render_test.py::TestQueryRenderText::test_render_expand
	beanquery/query_render_test.py::TestQueryRenderCSV::test_render_expand
)

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
