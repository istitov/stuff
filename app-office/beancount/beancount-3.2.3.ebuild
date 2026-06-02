# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=meson-python
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="A double-entry accounting system that uses text files as input"
HOMEPAGE="
	https://beancount.github.io
	https://github.com/beancount/beancount
"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/click[${PYTHON_USEDEP}]
	dev-python/python-dateutil[${PYTHON_USEDEP}]
	dev-python/regex[${PYTHON_USEDEP}]
"
# meson.build resolves bison/flex via find_program() and generates the
# parser at build time, so the v2 hand-rolled grammar/lexer rebuild dance
# is gone — these are pure build tools now.
BDEPEND="
	>=sys-devel/bison-3.8.0
	>=sys-devel/flex-2.6.4
"

# The suite uses only stock pytest + unittest (self.subTest is built-in,
# not pytest-subtests), so load no third-party plugins.
EPYTEST_PLUGINS=()

EPYTEST_DESELECT=(
	# Both call find_repository_root() to locate the top-level examples/
	# ledgers, which live in the source tree only — not installed as part
	# of the Python package, so they cannot pass against the install tree.
	projects/export_test.py::TestExport::test_export_basic
	scripts/check_examples_test.py::TestCheckExamples::test_example_files
)

distutils_enable_tests pytest

python_test() {
	# Run against the installed copy from an empty dir: the C _parser
	# extension is built into the meson install tree, not in-place in
	# ${S}, so collecting tests from the source tree fails to import it.
	cd "${T}" || die
	epytest --pyargs beancount
}
