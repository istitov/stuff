# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Cython build hooks for hatch"
HOMEPAGE="
	https://github.com/joshua-auchincloss/hatch-cython
	https://pypi.org/project/hatch-cython/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Build-backend plugin required by vispy since 0.17. typing-extensions applies
# only below this package's Python floor. # verified 2026-09-09
RDEPEND="
	dev-python/cython[${PYTHON_USEDEP}]
	dev-python/hatchling[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
"

BDEPEND="
	test? (
		$(python_gen_cond_dep '
			dev-python/numpy[${PYTHON_USEDEP}]
			dev-python/toml[${PYTHON_USEDEP}]
		')
	)
"

EPYTEST_PLUGINS=( pytest-cov )
EPYTEST_DESELECT=(
	# Marker parsing mishandles two-digit Python minors and emits a py39 flag;
	# vispy uses no markers. # verified 2026-09-09
	tests/test_config.py::test_config_parser
)
distutils_enable_tests pytest

python_test() {
	# Upstream lacks pytest rootdir config; expose its tests package.
	local -x PYTHONPATH="${S}"

	# test_libraries contains unbuilt Hatch integration fixtures.
	# verified 2026-09-09
	epytest tests
}
