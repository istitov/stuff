# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=meson-python
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="A double-entry accounting system that uses text files as input"
HOMEPAGE="
	https://beancount.github.io
	https://github.com/beancount/beancount
"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	dev-python/click[${PYTHON_USEDEP}]
	dev-python/python-dateutil[${PYTHON_USEDEP}]
	dev-python/regex[${PYTHON_USEDEP}]
"
# Meson generates the parser at build time, so bison and flex are build-only.
BDEPEND="
	>=sys-devel/bison-3.8.0
	>=sys-devel/flex-2.6.4
"

# Load no third-party pytest plugins.
EPYTEST_PLUGINS=()

EPYTEST_DESELECT=(
	# These require source-only example ledgers and fail against the install tree.
	projects/export_test.py::TestExport::test_export_basic
	scripts/check_examples_test.py::TestCheckExamples::test_example_files
)

distutils_enable_tests pytest

python_test() {
	# Run from an empty directory so pytest imports the installed C extension.
	cd "${T}" || die
	epytest --pyargs beancount
}
