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

# Packaged as the build backend plugin dev-python/vispy needs from 0.17.0:
# upstream moved off setuptools to hatchling plus this cython build hook.
# It is a BDEPEND of that package, not a runtime import for anything.
#
# typing-extensions is upstream-gated on python_version < 3.10, below the
# floor here, so it is deliberately absent. # verified 2026-09-09
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
	# Upstream bug, not a packaging one: the fixture config gates a flag on
	# marker = "python_version == '3.9'", and hatch-cython emits it anyway on
	# 3.13, so the parsed args carry an extra -py39. Its marker evaluation
	# does not handle two-digit minor versions. dev-python/vispy, the only
	# consumer here, configures the hook without markers and is unaffected.
	# verified 2026-09-09
	tests/test_config.py::test_config_parser
)
distutils_enable_tests pytest

python_test() {
	# tests/ is a package (it has __init__.py) and upstream ships no pytest
	# rootdir config, so `tests.*` only resolves with the source tree on the
	# path.
	local -x PYTHONPATH="${S}"

	# Only tests/ is unit-level. test_libraries/ are integration fixtures that
	# import example packages which upstream builds first with hatch; without
	# that step they cannot even be collected. # verified 2026-09-09
	epytest tests
}
