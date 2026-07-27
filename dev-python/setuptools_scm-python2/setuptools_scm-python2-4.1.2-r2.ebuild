# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DISTUTILS_USE_SETUPTOOLS=manual
PYTHON_COMPAT=( python2_7 )
_PYTHON_ALLOW_PY27=1
DISTUTILS_OPTIONAL=1
inherit distutils-r1_py2 pypi

MYPN="${PN/-python2/}"
MYP="${MYPN}-${PV}"

DESCRIPTION="Manage versions by scm tags via setuptools"
HOMEPAGE="https://github.com/pypa/setuptools-scm https://pypi.org/project/setuptools-scm/"
SRC_URI="$(pypi_sdist_url --no-normalize "${MYPN}" "${PV}")"

S="${WORKDIR}/${MYP}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
#IUSE="test"
#RESTRICT="!test? ( test )"

#	test? (
#		dev-python/pytest[${PYTHON_USEDEP}]
#		dev-python/toml[${PYTHON_USEDEP}]
#		dev-vcs/git
#		!sparc? ( dev-vcs/mercurial ) )"

# DISTUTILS_OPTIONAL suppresses the eclass's PYTHON_DEPS and
# PYTHON_REQUIRED_USE. The interpreter was declared here as a literal atom,
# but REQUIRED_USE was left empty, so nothing forced a python target to be
# selected. Take both from the eclass variables instead, which also keeps any
# future PYTHON_REQ_USE working. verified 2026-07-27
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}
	dev-python/setuptools-python2[${PYTHON_USEDEP}]
"
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
