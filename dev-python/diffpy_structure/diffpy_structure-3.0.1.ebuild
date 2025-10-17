# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
MYPN="${PN/_/.}"
MYP="${MYPN}-${PV}"
PYTHON_COMPAT=( python3_{9..12} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 flag-o-matic pypi

DESCRIPTION="Crystal structure container and parsers for structure formats"
HOMEPAGE="https://github.com/diffpy/diffpy.structure"
SRC_URI="$(pypi_sdist_url --no-normalize "${MYPN}" "${PV}")"
S=${WORKDIR}/${MYP}


LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/numpy-1.5.1[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
"
