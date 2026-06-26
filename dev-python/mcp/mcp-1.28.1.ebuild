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

RDEPEND="
	>=dev-python/anyio-4.9.0[${PYTHON_USEDEP}]
	>=dev-python/httpx-0.27.1[${PYTHON_USEDEP}]
	>=dev-python/httpx-sse-0.4.0[${PYTHON_USEDEP}]
	>=dev-python/jsonschema-4.20.0[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.12.0[${PYTHON_USEDEP}]
	>=dev-python/pydantic-settings-2.5.2[${PYTHON_USEDEP}]
	>=dev-python/pyjwt-2.10.1[${PYTHON_USEDEP}]
	>=dev-python/cryptography-3.4.0[${PYTHON_USEDEP}]
	>=dev-python/python-multipart-0.0.9[${PYTHON_USEDEP}]
	>=dev-python/sse-starlette-3.0.0[${PYTHON_USEDEP}]
	>=dev-python/starlette-0.27.0[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.13.0[${PYTHON_USEDEP}]
	>=dev-python/typing-inspection-0.4.1[${PYTHON_USEDEP}]
	>=dev-python/uvicorn-0.31.1[${PYTHON_USEDEP}]
	cli? (
		>=dev-python/python-dotenv-1.0.0[${PYTHON_USEDEP}]
		>=dev-python/typer-0.16.0[${PYTHON_USEDEP}]
	)
"
# Tests pull pytest-examples (depends on missing ruff Python bindings)
# plus a pile of dev-python/* deps; not worth running in our overlay.
RESTRICT="test"

pkg_postinst() {
	optfeature "colorized log output" dev-python/rich
	optfeature "WebSockets support" dev-python/websockets
}
