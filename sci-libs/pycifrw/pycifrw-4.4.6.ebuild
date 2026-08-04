# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 pypi

DESCRIPTION="Reading and writing CIF (Crystallographic Information Format) files"
HOMEPAGE="https://pypi.org/project/PyCifRW/ https://github.com/jamesrhester/pycifrw/"
SRC_URI="
	https://github.com/jamesrhester/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.gh.tar.gz
	https://files.pythonhosted.org/packages/source/P/PyCifRW/PyCifRW-${PV}.tar.gz -> ${P}.pypi.tar.gz
"
S="${WORKDIR}/PyCifRW-${PV}"

LICENSE="PyCifRW"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

RDEPEND="
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/ply[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=()
EPYTEST_DESELECT=(
	# upstream documents this as failing due to its indentation expectation
	TestDrel.py::SingleSimpleStatementTestCase::testlongstring
	# require the separately absent tests/drel/cif_core.dic fixture
	TestDrel.py::MoreComplexTestCase::test_fancy_assign
	TestDrel.py::WithDictTestCase
)
distutils_enable_tests pytest

src_prepare() {
	distutils-r1_src_prepare

	# The release sdist has generated modules but omits its test fixtures.
	cp -R "${WORKDIR}/${P}"/{dictionaries,tests} . || die

	# Python 3.13 removed this deprecated unittest assertion alias.
	sed -e 's/\.failUnless(/.assertTrue(/g' -i Test{Drel,PyCIFRW}.py || die
}

python_test() {
	local install_dir="${BUILD_DIR}/install$(python_get_sitedir)/CifFile/drel"

	cp -p "${install_dir}/parsetab.py" "${T}" || die
	epytest TestPyCIFRW.py TestDrel.py
	cp -p "${T}/parsetab.py" "${install_dir}" || die
	rm "${install_dir}/parser.out" || die
}
