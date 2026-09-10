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

# Package import eagerly loads agent_idp's cryptography/Ed25519 code, making
# this a hard dependency. # verified 2026-09-02 against the 0.4.0 sdist
RDEPEND="
	>=dev-python/cryptography-41[${PYTHON_USEDEP}]
	>=dev-python/filelock-3.9[${PYTHON_USEDEP}]
	>=dev-python/requests-2.28[${PYTHON_USEDEP}]
	>=dev-python/tqdm-4.64.0[${PYTHON_USEDEP}]
	>=dev-python/urllib3-1.26[${PYTHON_USEDEP}]
"

# The suite uses unittest.mock, not pytest-mock; responses is imported as a
# library rather than a pytest plugin. # verified 2026-08-29
BDEPEND="
	test? (
		>=dev-python/responses-0.20[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_test() {
	# The remote marker requires API credentials. The sdist also omits the
	# OpenAPI fixture used only by upstream's spec-drift checks; recheck on bump.
	# verified 2026-09-02
	local EPYTEST_DESELECT=( tests/test_openapi_coverage.py )
	epytest -m "not remote"
}
