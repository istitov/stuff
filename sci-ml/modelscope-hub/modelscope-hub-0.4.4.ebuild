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
KEYWORDS="~amd64 ~arm64"

# cryptography is unconditional: agent_idp imports its serialization and
# Ed25519 APIs at module scope, and the package root imports agent_idp.
RDEPEND="
	>=dev-python/cryptography-41[${PYTHON_USEDEP}]
	>=dev-python/filelock-3.9[${PYTHON_USEDEP}]
	>=dev-python/requests-2.28[${PYTHON_USEDEP}]
	>=dev-python/tqdm-4.64.0[${PYTHON_USEDEP}]
	>=dev-python/urllib3-1.26[${PYTHON_USEDEP}]
"

# The suite uses responses as a library, not a pytest plugin, and does not use
# the pytest-mock fixture listed in upstream's dev extra.
BDEPEND="
	test? (
		>=dev-python/responses-0.20[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_test() {
	# `remote` tests require ModelScope credentials. The OpenAPI coverage tests
	# need tests/data/openapi.json, which is absent from the sdist.
	local EPYTEST_DESELECT=( tests/test_openapi_coverage.py )
	epytest -m "not remote"
}
