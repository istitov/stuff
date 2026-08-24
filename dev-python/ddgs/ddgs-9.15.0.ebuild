# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Metasearch library with DuckDuckGo and other search backends"
HOMEPAGE="
	https://github.com/deedy5/ddgs
	https://pypi.org/project/ddgs/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/click-8.1.8[${PYTHON_USEDEP}]
	>=dev-python/primp-1.2.3[${PYTHON_USEDEP}]
	>=dev-python/lxml-4.9.4[${PYTHON_USEDEP}]
	>=dev-python/httpx2-2.7.0[${PYTHON_USEDEP}]
	dev-python/h2[${PYTHON_USEDEP}]
	dev-python/socksio[${PYTHON_USEDEP}]
	dev-python/brotlicffi[${PYTHON_USEDEP}]
	>=dev-python/fake-useragent-2.2.0[${PYTHON_USEDEP}]
"

# Most tests query live public search services.
RESTRICT="test"

PATCHES=( "${FILESDIR}/${P}-httpx2.patch" )
