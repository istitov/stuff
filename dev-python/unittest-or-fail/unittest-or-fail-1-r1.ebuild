# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

_PYTHON_ALLOW_PY27=1
DISTUTILS_OPTIONAL=1
PYTHON_COMPAT=( python2_7 )
#Please note, that the original ebuild is not supporting py2_7
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

# DISTUTILS_OPTIONAL suppresses the eclass's PYTHON_DEPS and
# PYTHON_REQUIRED_USE and leaves them to the ebuild. This one declared no
# dependencies at all, so a Python 2 module installed with nothing requiring
# a Python 2 interpreter, and no target constraint either.
# verified 2026-07-27
RDEPEND="${PYTHON_DEPS}"

# Upstream is python3 code; two things break it under python2.7:
#  - setup.py declares a non-ASCII author with no PEP 263 encoding line, a
#    SyntaxError under python2.7 -- so install the module directly instead of
#    running setup.py;
#  - the module's run() uses a python3-only zero-arg super() (patched).
# distutils_enable_tests is avoided (it would add a circular dep on this
# package), so no tests are run.
PATCHES=( "${FILESDIR}/${P}-python2-super.patch" )

src_install() {
	python_foreach_impl python_domodule "${S}"/unittest_or_fail.py
}
