# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="C binding automation — parses C headers for ABI generation"
HOMEPAGE="
	https://github.com/MatthieuDartiailh/pyclibrary
	https://pypi.org/project/pyclibrary/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/pyparsing-2.3.1[${PYTHON_USEDEP}]
	<dev-python/pyparsing-4[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
