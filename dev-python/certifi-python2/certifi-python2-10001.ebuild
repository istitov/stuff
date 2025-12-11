# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DISTUTILS_USE_SETUPTOOLS=no
_PYTHON_ALLOW_PY27=1
DISTUTILS_OPTIONAL=1
PYTHON_COMPAT=( python2_7 )

inherit distutils-r1_py2

MY_P=certifi-shim-${PV}
DESCRIPTION="Thin replacement for certifi using system certificate store"
HOMEPAGE="
	https://github.com/mgorny/certifi-shim
	https://pypi.org/project/certifi"
SRC_URI="
	https://github.com/mgorny/certifi-shim/archive/v${PV}.tar.gz
		-> ${MY_P}.tar.gz"
S=${WORKDIR}/${MY_P}

LICENSE="CC0-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="app-misc/ca-certificates"

distutils_enable_tests unittest

src_prepare() {
	default
	sed -i -e "s^/etc^${EPREFIX}/etc^" certifi/core.py || die
	distutils-r1_src_prepare
}

src_compile() {
	python_foreach_impl _distutils-r1_copy_egg_info
	python_foreach_impl esetup.py build  "${build_args[@]}" "${@}"
}

src_install() {
	python_foreach_impl distutils-r1_python_install
}
