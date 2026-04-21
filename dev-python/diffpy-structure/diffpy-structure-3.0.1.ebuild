# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYPI_PN="${PN/-/.}"
PYPI_NO_NORMALIZE=1
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 pypi

DESCRIPTION="Crystal structure container and parsers for structure formats"
HOMEPAGE="https://github.com/diffpy/diffpy.structure"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/numpy-1.5.1[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
"
