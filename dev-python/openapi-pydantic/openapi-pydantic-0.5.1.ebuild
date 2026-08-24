# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry
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
BDEPEND="
	>=dev-python/poetry-core-1.0.0[${PYTHON_USEDEP}]
	test? (
		>=dev-python/openapi-spec-validator-0.7.0[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest
