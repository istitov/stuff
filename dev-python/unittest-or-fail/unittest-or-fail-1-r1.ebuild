# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

_PYTHON_ALLOW_PY27=1
DISTUTILS_OPTIONAL=1
PYTHON_COMPAT=( python2_7 )
inherit distutils-r1_py2

DESCRIPTION="Run unittests or fail if no tests were found"
HOMEPAGE="https://github.com/projg2/unittest-or-fail/"
SRC_URI="
	https://github.com/projg2/unittest-or-fail/archive/v${PV}.tar.gz
		-> ${P}.tar.gz"

LICENSE="BSD-2"
SLOT="2"
KEYWORDS="amd64 ~arm64 x86"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# DISTUTILS_OPTIONAL suppresses interpreter dependencies and target constraints;
# supply both from the eclass variables.
# verified 2026-07-27
RDEPEND="${PYTHON_DEPS}"

# setup.py lacks a Python 2 encoding declaration, so install the module
# directly; patch its zero-argument super(). Tests would create a circular dep.
PATCHES=( "${FILESDIR}/${P}-python2-super.patch" )

src_install() {
	python_foreach_impl python_domodule "${S}"/unittest_or_fail.py
}
