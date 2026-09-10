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

# 9.16 replaces httpx and fake-useragent with primp; no Python source imports
# either former dependency. verified 2026-08-27
RDEPEND="
	>=dev-python/click-8.1.8[${PYTHON_USEDEP}]
	>=dev-python/primp-1.3.1[${PYTHON_USEDEP}]
	>=dev-python/lxml-4.9.4[${PYTHON_USEDEP}]
"

# Most tests query live public search services.
RESTRICT="test"
