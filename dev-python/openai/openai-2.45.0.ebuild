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

RDEPEND="
	>=dev-python/anyio-3.5.0[${PYTHON_USEDEP}]
	>=dev-python/distro-1.7.0[${PYTHON_USEDEP}]
	>=dev-python/httpx-0.23.0[${PYTHON_USEDEP}]
	>=dev-python/jiter-0.10.0[${PYTHON_USEDEP}]
	>=dev-python/pydantic-1.9.0[${PYTHON_USEDEP}]
	dev-python/sniffio[${PYTHON_USEDEP}]
	>=dev-python/tqdm-4.0[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.14[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/hatch-fancy-pypi-readme[${PYTHON_USEDEP}]
"

# Tests need the same Stainless mock-server stack as anthropic.
RESTRICT="test"
