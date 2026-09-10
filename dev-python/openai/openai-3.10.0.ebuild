# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="The official Python library for the openai API"
HOMEPAGE="
	https://github.com/openai/openai-python
	https://pypi.org/project/openai/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Since 3.6, stdlib os-release parsing replaces distro. Transcribe upstream's
# effective floors and major ceilings; its excluded Pydantic 2.0-2.3 range is
# older than ::gentoo, and sniffio is intentionally unbounded.
# verified 2026-09-09 against 3.10.0 PKG-INFO
RDEPEND="
	>=dev-python/anyio-4.10.0[${PYTHON_USEDEP}]
	<dev-python/anyio-5[${PYTHON_USEDEP}]
	>=dev-python/httpx2-2.7.0[${PYTHON_USEDEP}]
	<dev-python/httpx2-3[${PYTHON_USEDEP}]
	>=dev-python/jiter-0.16.0[${PYTHON_USEDEP}]
	<dev-python/jiter-1[${PYTHON_USEDEP}]
	>=dev-python/pydantic-1.10.13[${PYTHON_USEDEP}]
	<dev-python/pydantic-3[${PYTHON_USEDEP}]
	dev-python/sniffio[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.14[${PYTHON_USEDEP}]
	<dev-python/typing-extensions-5[${PYTHON_USEDEP}]
"
# Tests need the same Stainless mock-server stack as anthropic.
RESTRICT="test"
