# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYPI_VERIFY_REPO=https://github.com/modelcontextprotocol/python-sdk
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 optfeature pypi

DESCRIPTION="Model Context Protocol SDK"
HOMEPAGE="
	https://modelcontextprotocol.io/docs/getting-started/intro
	https://github.com/modelcontextprotocol/python-sdk
	https://pypi.org/project/mcp/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="cli"

# MCP 2 moved transport to httpx2, split exact-version wire types into
# mcp-types, and added OpenTelemetry; it dropped httpx-sse and pydantic-settings.
RDEPEND="
	>=dev-python/anyio-4.10.0[${PYTHON_USEDEP}]
	>=dev-python/httpx2-2.5.0[${PYTHON_USEDEP}]
	>=dev-python/jsonschema-4.20.0[${PYTHON_USEDEP}]
	~dev-python/mcp-types-2.1.1[${PYTHON_USEDEP}]
	>=dev-python/opentelemetry-api-1.28.0[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.12.0[${PYTHON_USEDEP}]
	>=dev-python/pyjwt-2.10.1[${PYTHON_USEDEP}]
	>=dev-python/cryptography-3.4.0[${PYTHON_USEDEP}]
	>=dev-python/python-multipart-0.0.9[${PYTHON_USEDEP}]
	>=dev-python/sse-starlette-3.0.0[${PYTHON_USEDEP}]
	>=dev-python/starlette-0.48.0[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.13.0[${PYTHON_USEDEP}]
	>=dev-python/typing-inspection-0.4.1[${PYTHON_USEDEP}]
	>=dev-python/uvicorn-0.31.1[${PYTHON_USEDEP}]
	cli? (
		>=dev-python/python-dotenv-1.0.0[${PYTHON_USEDEP}]
		>=dev-python/typer-0.16.0[${PYTHON_USEDEP}]
	)
"
BDEPEND="
	>=dev-python/uv-dynamic-versioning-0.8.0[${PYTHON_USEDEP}]
"
# Tests require pytest-examples and unavailable ruff Python bindings.
RESTRICT="test"

# Pin the VCS-derived version for the sdist.
export UV_DYNAMIC_VERSIONING_BYPASS=${PV}

pkg_postinst() {
	optfeature "colorized log output" dev-python/rich
	optfeature "WebSockets support" dev-python/websockets
}
