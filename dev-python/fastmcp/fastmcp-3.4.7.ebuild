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

RDEPEND="
	>=dev-python/platformdirs-4.0.0[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.11.7[${PYTHON_USEDEP}]
	dev-python/email-validator[${PYTHON_USEDEP}]
	>=dev-python/pydantic-settings-2.0.0[${PYTHON_USEDEP}]
	>=dev-python/python-dotenv-1.1.0[${PYTHON_USEDEP}]
	>=dev-python/rich-13.9.4[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.0.0[${PYTHON_USEDEP}]
	>=dev-python/exceptiongroup-1.2.2[${PYTHON_USEDEP}]
	>=dev-python/mcp-1.24.0[${PYTHON_USEDEP}]
	<dev-python/mcp-2[${PYTHON_USEDEP}]
	>=dev-python/opentelemetry-api-1.20.0[${PYTHON_USEDEP}]
	>=dev-python/starlette-1.0.1[${PYTHON_USEDEP}]
	>=dev-python/authlib-1.6.11[${PYTHON_USEDEP}]
	>=dev-python/py-key-value-aio-0.4.4[${PYTHON_USEDEP}]
	<dev-python/py-key-value-aio-0.5[${PYTHON_USEDEP}]
	>=dev-python/cyclopts-4.0.0[${PYTHON_USEDEP}]
	>=dev-python/griffelib-2.0.0[${PYTHON_USEDEP}]
	>=dev-python/jsonref-1.1.0[${PYTHON_USEDEP}]
	>=dev-python/jsonschema-path-0.3.4[${PYTHON_USEDEP}]
	>=dev-python/joserfc-1.1.0[${PYTHON_USEDEP}]
	>=dev-python/openapi-pydantic-0.5.1[${PYTHON_USEDEP}]
	>=dev-python/packaging-24.0[${PYTHON_USEDEP}]
	>=dev-python/pyperclip-1.9.0[${PYTHON_USEDEP}]
	>=dev-python/python-multipart-0.0.26[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-6.0[${PYTHON_USEDEP}]
	<dev-python/pyyaml-7.0[${PYTHON_USEDEP}]
	>=dev-python/uncalled-for-0.2.0[${PYTHON_USEDEP}]
	>=dev-python/uvicorn-0.35[${PYTHON_USEDEP}]
	>=dev-python/watchfiles-1.0.0[${PYTHON_USEDEP}]
	>=dev-python/websockets-15.0.1[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/hatchling[${PYTHON_USEDEP}]
	>=dev-python/uv-dynamic-versioning-0.7.0[${PYTHON_USEDEP}]
"

# mcp carries the exact upstream-required HTTPX runtime.  Keeping it
# transitive avoids adding a direct dependency Gentoo has deprecated.

# The upstream suite requires its full development workspace and live service
# integrations, including Node-based MCP conformance tests.
RESTRICT="test"

export UV_DYNAMIC_VERSIONING_BYPASS=${PV}
