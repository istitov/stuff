# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Shared Pydantic types for the Model Context Protocol SDK"
HOMEPAGE="
	https://github.com/modelcontextprotocol/python-sdk
	https://pypi.org/project/mcp-types/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/pydantic-2.12.0[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.13.0[${PYTHON_USEDEP}]
"
BDEPEND="
	>=dev-python/uv-dynamic-versioning-0.8.0[${PYTHON_USEDEP}]
"

# The types-only sdist omits tests.
RESTRICT="test"

# The sdist lacks VCS metadata; bypass uv-dynamic-versioning with ${PV}.
export UV_DYNAMIC_VERSIONING_BYPASS=${PV}
