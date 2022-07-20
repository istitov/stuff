# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DISTUTILS_USE_SETUPTOOLS=manual
PYTHON_COMPAT=( python2_7 )
_PYTHON_ALLOW_PY27=1
DISTUTILS_OPTIONAL=1
inherit distutils-r1

MYPN="${PN/-python2/}"
MYP="${MYPN}-${PV}"

DESCRIPTION="Manage versions by scm tags via setuptools"
HOMEPAGE="https://github.com/pypa/setuptools_scm https://pypi.org/project/setuptools_scm/"
SRC_URI="mirror://pypi/${MYPN:0:1}/${MYPN}/${MYP}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~s390 ~sparc ~x86 ~x64-cygwin ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
#IUSE="test"
#RESTRICT="!test? ( test )"

BDEPEND="
	!!<dev-python/setuptools_scm-2
"
#	test? (
#		dev-python/pytest[${PYTHON_USEDEP}]
#		dev-python/toml[${PYTHON_USEDEP}]
#		dev-vcs/git
#		!sparc? ( dev-vcs/mercurial ) )"

RDEPEND="
	dev-lang/python:2.7
	dev-python/setuptools-python2[${PYTHON_USEDEP}]
"
S="${WORKDIR}/${MYP}"
src_prepare() {
	default
	# network access
	sed -i -e 's:test_pip_download:_&:' testing/test_regressions.py || die
	# all fetch specific setuptools versions
	rm testing/test_setuptools_support.py || die

	distutils-r1_python_prepare_all
}

src_compile() {
	python_foreach_impl _distutils-r1_copy_egg_info
	python_foreach_impl esetup.py build  "${build_args[@]}" "${@}"
}

src_test() {
	distutils_install_for_testing
	pytest -v -v -x || die "Tests fail with ${EPYTHON}"
}

src_install() {
	python_foreach_impl distutils-r1_python_install
}
