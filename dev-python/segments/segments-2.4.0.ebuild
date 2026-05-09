# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Unicode segmentation profiles based on Moisik & Esling 2011"
HOMEPAGE="
	https://github.com/cldf/segments
	https://pypi.org/project/segments/
"
SRC_URI="https://github.com/cldf/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.gh.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	${PYTHON_DEPS}
	>=dev-python/csvw-1.5.6[${PYTHON_USEDEP}]
	dev-python/regex[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}"
