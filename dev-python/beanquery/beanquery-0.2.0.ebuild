# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Customizable lightweight SQL query tool for Beancount (BQL)"
HOMEPAGE="
	https://github.com/beancount/beanquery
	https://pypi.org/project/beanquery/
"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=app-office/beancount-2.3.4[${PYTHON_USEDEP}]
	>=dev-python/click-8.1[${PYTHON_USEDEP}]
	>=dev-python/python-dateutil-2.6.0[${PYTHON_USEDEP}]
	dev-python/tatsu-lts[${PYTHON_USEDEP}]
"

# Load no third-party pytest plugins.
EPYTEST_PLUGINS=()

# Beancount 3.2 added a sign-alignment column, invalidating these exact-width
# assertions without breaking output. Revisit after upstream updates them.
# verified 2026-06-02
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
	# Limit package discovery; upstream's bare find also installs docs/.
	grep -q '^find = {}$' pyproject.toml || die "package-discovery stanza moved"
	sed -i \
		-e 's/^\[tool\.setuptools\.packages\]$/[tool.setuptools.packages.find]/' \
		-e 's/^find = {}$/include = ["beanquery*"]/' \
		pyproject.toml || die
	distutils-r1_python_prepare_all
}
