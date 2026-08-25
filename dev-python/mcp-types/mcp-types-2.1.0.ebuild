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

# upstream declares its only runtime deps as pydantic + typing-extensions.
RDEPEND="
	>=dev-python/pydantic-2.12.0[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.13.0[${PYTHON_USEDEP}]
"
BDEPEND="
	>=dev-python/uv-dynamic-versioning-0.8.0[${PYTHON_USEDEP}]
"

# The sdist ships no test suite (types-only package).
RESTRICT="test"

# Version source is the uv-dynamic-versioning hatch plugin, which derives from
# VCS; the sdist is not a checkout, so pin the version explicitly.
export UV_DYNAMIC_VERSIONING_BYPASS=${PV}
