# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Model and dataset hub client core for ModelScope"
HOMEPAGE="
	https://github.com/modelscope/modelscope
	https://pypi.org/project/modelscope-hub/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# cryptography is NEW in 0.4.0 and is unconditional, not an optional
# integration: the new agent_idp module does a module-scope `from
# cryptography.hazmat.primitives import serialization` (plus Ed25519PrivateKey)
# for agent-token signing, and __init__.py imports agent_idp at package root,
# so a bare `import modelscope_hub` needs it. verified 2026-09-02 against the
# unpacked 0.4.0 sdist.
RDEPEND="
	>=dev-python/cryptography-41[${PYTHON_USEDEP}]
	>=dev-python/filelock-3.9[${PYTHON_USEDEP}]
	>=dev-python/requests-2.28[${PYTHON_USEDEP}]
	>=dev-python/tqdm-4.64.0[${PYTHON_USEDEP}]
	>=dev-python/urllib3-1.26[${PYTHON_USEDEP}]
"

# Upstream's `dev` extra also lists pytest-mock, but the suite never uses the
# `mocker` fixture -- every test mocks with stdlib unittest.mock. responses is
# the only real test dep, and it is used as a plain library (@responses.activate),
# not as a pytest plugin, hence the empty EPYTEST_PLUGINS. verified 2026-08-29
BDEPEND="
	test? (
		>=dev-python/responses-0.20[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_test() {
	# Upstream marks the cases that hit the live ModelScope API with a
	# `remote` pytest marker and documents them as needing .env credentials
	# (see [tool.pytest.ini_options] in pyproject.toml). Deselect that marker
	# rather than RESTRICT the whole suite -- the sdist has shipped a tests/
	# tree since 0.2.0 and it was going unrun. verified 2026-08-29
	#
	# test_openapi_coverage.py is NEW in 0.4.0 and cannot run from an sdist:
	# all six of its cases read tests/data/openapi.json, a vendored copy of
	# the live OpenAPI document, and the sdist ships no tests/data/ directory
	# at all (there is no openapi.json anywhere in it). They are spec-drift
	# guards for upstream's own repo, not tests of the built package, so
	# deselecting loses no coverage of what we ship. Without this the phase
	# fails 296 passed / 6 errors on FileNotFoundError. Re-check on each bump
	# in case upstream starts shipping the fixture. verified 2026-09-02
	local EPYTEST_DESELECT=( tests/test_openapi_coverage.py )
	epytest -m "not remote"
}
