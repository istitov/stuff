# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Fast framework for building Model Context Protocol servers"
HOMEPAGE="
	https://github.com/PrefectHQ/fastmcp
	https://pypi.org/project/fastmcp/
"

# The root project is an empty metapackage.  Build the implementation that it
# pins and bundles in the same release sdist.
S="${WORKDIR}/${P}/fastmcp_slim"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# The root fastmcp metapackage resolves to fastmcp-slim[client,server], and
# both of those extras pull fastmcp-slim[mcp] -- so what we ship is the union
# of the base deps plus the mcp, client and server groups. Grouped that way
# below to keep it checkable against fastmcp_slim/pyproject.toml. The other
# extras (anthropic, apps, azure, code-mode, gemini, openai) are provider
# integrations the metapackage does not pull; their deps -- prefab-ui,
# azure-identity, pydantic-monty, google-genai -- are unpackaged anyway.
#
# 4.0.0 restructured this substantially versus 3.4.7: mcp-types and httpx2 are
# new, mcp moved from the 1.x line to 2.x, and several floors were raised.
# Read from ${WORKDIR}/fastmcp-4.0.0/fastmcp_slim/pyproject.toml 2026-09-01.
RDEPEND="
	>=dev-python/mcp-types-2.0.0[${PYTHON_USEDEP}]
	<dev-python/mcp-types-3[${PYTHON_USEDEP}]
	>=dev-python/platformdirs-4.0.0[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.12.0[${PYTHON_USEDEP}]
	dev-python/email-validator[${PYTHON_USEDEP}]
	>=dev-python/pydantic-settings-2.0.0[${PYTHON_USEDEP}]
	>=dev-python/python-dotenv-1.1.0[${PYTHON_USEDEP}]
	>=dev-python/rich-13.9.4[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.0.0[${PYTHON_USEDEP}]
	>=dev-python/exceptiongroup-1.2.2[${PYTHON_USEDEP}]
	>=dev-python/httpx2-2.5.0[${PYTHON_USEDEP}]
	>=dev-python/mcp-2.0.0[${PYTHON_USEDEP}]
	<dev-python/mcp-3[${PYTHON_USEDEP}]
	>=dev-python/opentelemetry-api-1.28.0[${PYTHON_USEDEP}]
	>=dev-python/starlette-1.0.1[${PYTHON_USEDEP}]
	>=dev-python/authlib-1.6.11[${PYTHON_USEDEP}]
	>=dev-python/py-key-value-aio-0.4.4[${PYTHON_USEDEP}]
	<dev-python/py-key-value-aio-0.5[${PYTHON_USEDEP}]
	>=dev-python/cyclopts-4.0.0[${PYTHON_USEDEP}]
	>=dev-python/griffelib-2.0.0[${PYTHON_USEDEP}]
	>=dev-python/jsonref-1.1.0[${PYTHON_USEDEP}]
	>=dev-python/jsonschema-path-0.3.4[${PYTHON_USEDEP}]
	>=dev-python/joserfc-1.5.0[${PYTHON_USEDEP}]
	>=dev-python/openapi-pydantic-0.5.1[${PYTHON_USEDEP}]
	>=dev-python/packaging-24.0[${PYTHON_USEDEP}]
	>=dev-python/pyperclip-1.9.0[${PYTHON_USEDEP}]
	>=dev-python/python-multipart-0.0.26[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-6.0[${PYTHON_USEDEP}]
	<dev-python/pyyaml-7.0[${PYTHON_USEDEP}]
	>=dev-python/uncalled-for-0.4.0[${PYTHON_USEDEP}]
	>=dev-python/uvicorn-0.35[${PYTHON_USEDEP}]
	>=dev-python/watchfiles-1.0.0[${PYTHON_USEDEP}]
	>=dev-python/websockets-15.0.1[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/hatchling[${PYTHON_USEDEP}]
	>=dev-python/uv-dynamic-versioning-0.7.0[${PYTHON_USEDEP}]
"

# The 3.4.7 note about leaving the HTTPX runtime transitive through mcp no
# longer applies: at 4.0.0 upstream declares httpx2 directly in the mcp extra,
# with the comment "FastMCP uses httpx2 exclusively". httpx2 is a separate
# ::gentoo package from the deprecated dev-python/httpx, so depending on it
# directly carries none of the old objection.
#
# py-key-value-aio is requested as [filetree,keyring,memory]. Our ebuild has no
# IUSE and pulls aiofile+anyio (filetree), keyring (keyring) and cachetools
# (memory) unconditionally, so all three extras are already satisfied by the
# plain atom. verified 2026-09-01

# The upstream suite requires its full development workspace and live service
# integrations, including Node-based MCP conformance tests.
RESTRICT="test"

export UV_DYNAMIC_VERSIONING_BYPASS=${PV}
