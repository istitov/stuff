# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{6..10} )

inherit distutils-r1 flag-o-matic

DESCRIPTION="library for structural biology"
HOMEPAGE="https://project-gemmi.github.io/"
SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc python"

RDEPEND="
	sys-libs/zlib
	dev-python/pybind11[${PYTHON_USEDEP}]
	dev-python/cython[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
"

DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

src_prepare() {
	sed -i -e "s:USE_SYSTEM_ZLIB = False:USE_SYSTEM_ZLIB = True:" "${S}"/setup.py  || die
	default
}
