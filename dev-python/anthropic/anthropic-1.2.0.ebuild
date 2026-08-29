# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 optfeature pypi

DESCRIPTION="The official Python library for the anthropic API"
HOMEPAGE="
	https://github.com/anthropics/anthropic-sdk-python
	https://pypi.org/project/anthropic/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# guru's ebuild fetched from GitHub for npm-driven mock-server tests;
# we strip that and use the PyPI sdist directly.
#
# 1.0.0 migrated the HTTP stack from httpx to httpx2 (>=2.0.0, from
# ::gentoo) and dropped the distro dependency; py-floor rose to 3.10
# (within our compat). verified 2026-08-21 against the 1.0.0 PyPI
# Requires-Dist, re-verified 2026-08-29 against the 1.2.0 sdist -- the
# runtime dep set is unchanged from 1.0.0.
# Upstream's major ceilings are carried through as well as the floors: these
# are real API-compat bounds Anthropic declares, not Dependabot noise, and
# without them a future ::gentoo bump to e.g. jiter 1.x or anyio 5.x would be
# silently accepted by this ebuild. verified 2026-08-29 against the 1.2.0
# sdist Requires-Dist.
RDEPEND="
	>=dev-python/anyio-3.5.0[${PYTHON_USEDEP}]
	<dev-python/anyio-5[${PYTHON_USEDEP}]
	>=dev-python/docstring-parser-0.15[${PYTHON_USEDEP}]
	<dev-python/docstring-parser-1[${PYTHON_USEDEP}]
	>=dev-python/httpx2-2.0.0[${PYTHON_USEDEP}]
	<dev-python/httpx2-3[${PYTHON_USEDEP}]
	>=dev-python/jiter-0.4.0[${PYTHON_USEDEP}]
	<dev-python/jiter-1[${PYTHON_USEDEP}]
	>=dev-python/pydantic-1.9.0[${PYTHON_USEDEP}]
	<dev-python/pydantic-3[${PYTHON_USEDEP}]
	>=dev-python/sniffio-1[${PYTHON_USEDEP}]
	<dev-python/sniffio-2[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.14[${PYTHON_USEDEP}]
	<dev-python/typing-extensions-5[${PYTHON_USEDEP}]
"
# anthropic (unlike openai 3.6.0) still uses the fancy-pypi-readme metadata
# hook; its build-system declares hatch-fancy-pypi-readme>=22.4,<26.
BDEPEND="
	>=dev-python/hatch-fancy-pypi-readme-22.4[${PYTHON_USEDEP}]
	<dev-python/hatch-fancy-pypi-readme-26[${PYTHON_USEDEP}]
"

# Tests need a Stainless mock-server stack (Node.js + npm registry
# fixtures); not worth running in our overlay.
RESTRICT="test"

pkg_postinst() {
	optfeature "alternative async HTTP client support" \
		">=dev-python/aiohttp-3.10.0"
	optfeature "Google Cloud Vertex AI integration" \
		">=dev-python/google-auth-2 dev-python/requests"
	optfeature "Amazon Web Services (AWS) Bedrock integration" \
		">=dev-python/boto3-1.28.57 >=dev-python/botocore-1.31.57"
	optfeature "Model Context Protocol (MCP) support" \
		">=dev-python/mcp-1.0"
}
