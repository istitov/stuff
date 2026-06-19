# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python wrapper for the Tavily search API"
HOMEPAGE="
	https://github.com/tavily-ai/tavily-python
	https://pypi.org/project/tavily-python/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/httpx[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	>=dev-python/tiktoken-0.5.1[${PYTHON_USEDEP}]
"

# Upstream ships no offline test suite — the tests drive the live Tavily
# API (needs an API key), so there is nothing to run in a sandboxed build.
RESTRICT="test"
