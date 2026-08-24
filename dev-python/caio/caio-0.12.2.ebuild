# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Asynchronous file IO for Linux and macOS"
HOMEPAGE="https://pypi.org/project/caio/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND="
	>=dev-python/setuptools-77[${PYTHON_USEDEP}]
"

# The upstream suite requires unpackaged test-only aiomisc.
RESTRICT="test"

PATCHES=( "${FILESDIR}/${P}-no-tests-package.patch" )
