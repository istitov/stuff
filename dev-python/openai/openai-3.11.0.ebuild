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

# 3.6.0 replaced distro with platform.freedesktop_os_release(). Mirror the
# pydantic floor/<3 cap and other upstream major caps; omitted pydantic 2.0-2.3
# is unavailable here, while sniffio is deliberately unbounded upstream.
# Verified against 3.11.0 metadata on 2026-09-10.
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
# The build system uses only hatchling; the former fancy-readme hook is gone.

# Tests require the unpackaged Stainless mock server.
RESTRICT="test"
