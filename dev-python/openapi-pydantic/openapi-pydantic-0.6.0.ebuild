# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Pydantic models for OpenAPI schemas"
HOMEPAGE="https://pypi.org/project/openapi-pydantic/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/pydantic-1.8[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=()
# Upstream caps the test-only openapi-spec-validator at <=0.8.3, below every
# version ::gentoo carries; skip the two modules that import it.
# verified 2026-10-02
EPYTEST_IGNORE=(
	tests/util/test_validated_schema.py
	tests/v3_0/test_validated_schema.py
)
distutils_enable_tests pytest
