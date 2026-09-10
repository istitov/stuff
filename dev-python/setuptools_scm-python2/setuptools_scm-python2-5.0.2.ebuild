# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

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
# DISTUTILS_OPTIONAL suppresses interpreter dependencies and target constraints;
# supply both from the eclass variables. verified 2026-07-27
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}
	dev-python/setuptools-python2[${PYTHON_USEDEP}]
"
src_prepare() {
	default
	# Disable the network-dependent pip download test.
	sed -i -e 's:test_pip_download:_&:' testing/test_regressions.py || die
	# Drop the suite that downloads specific setuptools releases.
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
