# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
PYTHON_COMPAT=( python2_7 )
_PYTHON_ALLOW_PY27=1
PYTHON_REQ_USE="threads(+)"

inherit distutils-r1

MYPN="${PN/-python2/}"
MYP="${MYPN}-${PV}"

DESCRIPTION="Python bindings for the cairo library"
HOMEPAGE="https://www.cairographics.org/pycairo/ https://github.com/pygobject/pycairo"
SRC_URI="https://github.com/pygobject/${MYPN}/releases/download/v${PV}/${MYP}.tar.gz"

LICENSE="|| ( LGPL-2.1 MPL-1.1 )"
SLOT="0"
KEYWORDS=""
#~alpha ~amd64 ~arm64 ~hppa ~ia64 ~mips ~ppc ~s390 ~sparc ~x86 ~ppc-macos ~x64-macos
IUSE="examples"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	>=x11-libs/cairo-1.13.1[svg]
"
DEPEND="${RDEPEND}"

PATCHES=( "${FILESDIR}/${MYPN}-1.19.1-py39.patch" )

S="${WORKDIR}/${MYP}"

python_compile() {
	esetup.py build
}

python_install() {
	distutils-r1_python_install \
		install_pkgconfig --pkgconfigdir="${EPREFIX}/usr/$(get_libdir)/pkgconfig"
}
