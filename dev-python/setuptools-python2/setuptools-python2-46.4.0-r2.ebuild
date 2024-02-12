# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
DISTUTILS_USE_SETUPTOOLS=no
_PYTHON_ALLOW_PY27=1
DISTUTILS_OPTIONAL=1
PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="xml(+)"

inherit distutils-r1_py2

MYPN="${PN/-python2/}"
MYP="${MYPN}-${PV}"

DESCRIPTION="Collection of extensions to Distutils"
HOMEPAGE="https://github.com/pypa/setuptools https://pypi.org/project/setuptools/"
SRC_URI="mirror://pypi/${MYPN:0:1}/${MYPN}/${MYP}.zip"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~s390 ~sparc ~x86 ~x64-cygwin ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

BDEPEND="
	dev-lang/python:2.7
	app-arch/unzip
"
# installing plugins apparently breaks stuff at runtime, so let's pull
# it early
PDEPEND="
	>=dev-python/certifi-python2-2016.9.26[${PYTHON_USEDEP}]
	dev-python/setuptools_scm-python2[${PYTHON_USEDEP}]"

# Force in-source build because build system modifies sources.
DISTUTILS_IN_SOURCE_BUILD=1
S="${WORKDIR}/${MYP}"
DOCS=( {CHANGES,README}.rst docs/{easy_install.txt,pkg_resources.txt,setuptools.txt} )

src_prepare_all() {
	# silence the py2 warning that is awfully verbose and breaks some
	# packages by adding unexpected output
	# (also, we know!)
	sed -i -e '/py2_warn/d' pkg_resources/__init__.py || die

	# disable tests requiring a network connection
	rm setuptools/tests/test_packageindex.py || die

	# don't run integration tests
	rm setuptools/tests/test_integration.py || die

	# xpass-es for me on py3
	sed -e '/xfail.*710/s:(:(six.PY2, :' \
		-i setuptools/tests/test_archive_util.py || die

	# avoid pointless dep on flake8
	sed -i -e 's:--flake8::' pytest.ini || die

	distutils-r1_python_prepare_all
}

python_test() {
	if ! python_is_python3; then
		einfo "Tests are skipped on py2 to untangle deps"
		return
	fi

	distutils_install_for_testing
	# test_easy_install raises a SandboxViolation due to ${HOME}/.pydistutils.cfg
	# It tries to sandbox the test in a tempdir
	HOME="${PWD}" pytest -vv ${MYPN} || die "Tests failed under ${EPYTHON}"
}

src_compile() {
	python_foreach_impl _distutils-r1_copy_egg_info
	python_foreach_impl esetup.py build  "${build_args[@]}" "${@}"
}

src_install() {
	export DISTRIBUTE_DISABLE_VERSIONED_EASY_INSTALL_SCRIPT=1
	python_foreach_impl distutils-r1_python_install
	mv "${D}"/usr/bin/easy_install "${D}"/usr/bin/easy_install_py2 || die
}
