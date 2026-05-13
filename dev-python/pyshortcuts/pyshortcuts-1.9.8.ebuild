# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 pypi

DESCRIPTION="Pyshortcuts helps to create desktop shortcuts that will run python scripts"
HOMEPAGE="https://github.com/newville/pyshortcuts"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	dev-python/charset-normalizer[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
