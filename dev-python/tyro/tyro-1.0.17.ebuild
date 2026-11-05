# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 pypi

DESCRIPTION="Zero-effort CLI interfaces and config objects from Python types"
HOMEPAGE="
	https://github.com/brentyi/tyro
	https://pypi.org/project/tyro/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"

# Flax and PyTorch belong only to the optional dev-nn extra.
RDEPEND="
	>=dev-python/docstring-parser-0.16[${PYTHON_USEDEP}]
	>=dev-python/typeguard-4.0.0[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.13.0[${PYTHON_USEDEP}]
"
# The flax and torch tests are skipped by conftest.py when those are absent.
BDEPEND="
	test? (
		dev-python/attrs[${PYTHON_USEDEP}]
		dev-python/msgspec[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/pydantic[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
		dev-python/shtab[${PYTHON_USEDEP}]
		$(python_gen_cond_dep '
			dev-python/omegaconf[${PYTHON_USEDEP}]
		' python3_{12..14})
	)
"

EPYTEST_PLUGINS=()
EPYTEST_XDIST=1
distutils_enable_tests pytest

python_test() {
	# ml_collections and universal-pathlib are not packaged, and these
	# tests import them unconditionally. verified 2026-11-05
	local EPYTEST_IGNORE=(
		tests/test_ml_collections.py
		tests/test_py311_generated/test_ml_collections_generated.py
	)
	# omegaconf does not support Python 3.15 yet.
	if ! python_has_version -b "dev-python/omegaconf[${PYTHON_USEDEP}]"; then
		EPYTEST_IGNORE+=(
			tests/test_unsupported_but_should_work.py
			tests/test_py311_generated/test_unsupported_but_should_work_generated.py
		)
	fi
	local EPYTEST_DESELECT=(
		tests/test_dcargs.py::test_upath
		tests/test_helptext.py::test_helptext_upath_defaults
		tests/test_py311_generated/test_dcargs_generated.py::test_upath
		tests/test_py311_generated/test_helptext_generated.py::test_helptext_upath_defaults
	)
	epytest
}
