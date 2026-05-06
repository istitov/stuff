# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="Consume Server-Sent Event (SSE) messages with HTTPX"
HOMEPAGE="
	https://github.com/florimondmanca/httpx-sse
	https://pypi.org/project/httpx-sse/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	dev-python/httpx[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
	dev-python/wheel[${PYTHON_USEDEP}]
"

# Tests need sse-starlette + a network fixture stack — skip in fork.
RESTRICT="test"
