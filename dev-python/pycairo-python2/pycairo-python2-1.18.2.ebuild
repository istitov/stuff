# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
PYTHON_COMPAT=( python2_7 )
_PYTHON_ALLOW_PY27=1
PYTHON_REQ_USE="threads(+)"
DISTUTILS_USE_SETUPTOOLS="manual"
#DISTUTILS_SINGLE_IMPL=1
DISTUTILS_OPTIONAL=1
inherit distutils-r1

MYPN="${PN/-python2/}"
MYP="${MYPN}-${PV}"

DESCRIPTION="Python bindings for the cairo library"
HOMEPAGE="https://www.cairographics.org/pycairo/ https://github.com/pygobject/pycairo"
SRC_URI="https://github.com/pygobject/${MYPN}/releases/download/v${PV}/${MYP}.tar.gz"

LICENSE="|| ( LGPL-2.1 MPL-1.1 )"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm64 ~hppa ~ia64 ~mips ~ppc ~s390 ~sparc ~x86 ~ppc-macos ~x64-macos"

IUSE="examples"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	dev-lang/python:2.7
	>=x11-libs/cairo-1.13.1[svg]
"
DEPEND="${RDEPEND}"

PATCHES=( "${FILESDIR}/${MYPN}-1.19.1-py39.patch" )

S="${WORKDIR}/${MYP}"
BUILD_DIR=${S}
src_compile() {
	python_foreach_impl _distutils-r1_copy_egg_info
	python_foreach_impl esetup.py build  "${build_args[@]}" "${@}"
}

src_install() {
	python_foreach_impl distutils-r1_python_install \
		install_pkgconfig --pkgconfigdir="${EPREFIX}/usr/$(get_libdir)/pkgconfig"
}
