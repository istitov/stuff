# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 pypi

MYPN="${PN/link-traits/link_traits}"
MYP="${MYPN}-${PV}"

DESCRIPTION="A fork to traitlets"
HOMEPAGE="https://github.com/hyperspy/link_traits"
#SRC_URI="mirror://pypi/${P:0:1}/${PN}/${MYP}.tar.gz"
SRC_URI="$(pypi_sdist_url "${PN^}" "${PV}")"

S="${WORKDIR}/${MYP}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

RDEPEND="
	dev-python/traits[${PYTHON_USEDEP}]
"
