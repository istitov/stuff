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

# 9.16.0 drops the httpx transport and fake-useragent outright: the sdist
# declares only click/primp/lxml, http_client2.py (the httpx path, carrying
# upstream's "# temporarily" pin) is deleted, and http_client.py now talks to
# primp alone. That retires httpx2/h2/socksio/brotlicffi/fake-useragent here,
# and with them the httpx2 rename patch -- its target file no longer exists.
# verified 2026-08-27 against the 9.16.0 sdist (no httpx or fake_useragent
# reference remains in any .py).
RDEPEND="
	>=dev-python/click-8.1.8[${PYTHON_USEDEP}]
	>=dev-python/primp-1.3.1[${PYTHON_USEDEP}]
	>=dev-python/lxml-4.9.4[${PYTHON_USEDEP}]
"

# Most tests query live public search services.
RESTRICT="test"
