# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Hatch plugin to build Sphinx documentation during wheel builds"
HOMEPAGE="
	https://github.com/llimeht/hatch-sphinx
	https://pypi.org/project/hatch-sphinx/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	dev-python/hatchling[${PYTHON_USEDEP}]
	dev-python/sphinx[${PYTHON_USEDEP}]
"
