# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DISTUTILS_USE_SETUPTOOLS=no
_PYTHON_ALLOW_PY27=1
DISTUTILS_OPTIONAL=1
PYTHON_COMPAT=( python2_7 )
#Please note, that the original ebuild is not supporting py2_7
inherit distutils-r1_py2

DESCRIPTION="Run unittests or fail if no tests were found"
HOMEPAGE="https://github.com/mgorny/unittest-or-fail/"
SRC_URI="
	https://github.com/mgorny/unittest-or-fail/archive/v${PV}.tar.gz
		-> ${P}.tar.gz"

LICENSE="BSD-2"
SLOT="2"
KEYWORDS="amd64 x86"

# Warning: do not use distutils_enable_tests to avoid a circular
# dependency on itself!

python_test() {
	"${EPYTHON}" -m unittest -v test/test_unittest_or_fail.py ||
		die "Tests failed with ${EPYTHON}"
}
