# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 pypi

DESCRIPTION="Reading and writing CIF (Crystallographic Information Format) files"
HOMEPAGE="https://pypi.org/project/PyCifRW/ https://github.com/jamesrhester/pycifrw/"
SRC_URI="https://github.com/jamesrhester/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="PyCifRW"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

RDEPEND="
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/ply[${PYTHON_USEDEP}]
	dev-python/prettytable[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=()
EPYTEST_DESELECT=(
	# require the separate tests/dictionaries fixture set
	TestPyCIFRW.py::DictTestCase
	TestPyCIFRW.py::DDL1TestCase
	TestPyCIFRW.py::DDLmDicTestCase
	TestPyCIFRW.py::DicEvalTestCase
	TestPyCIFRW.py::DicStructureTestCase
	TestDrel.py::TestMoreComplex::test_fancy_assign
	TestDrel.py::TestWithDict
)
distutils_enable_tests pytest

src_prepare() {
	distutils-r1_src_prepare
	python_setup
	emake -C src PYTHON="${EPYTHON}" Parsers
}

python_test() {
	epytest TestPyCIFRW.py TestDrel.py
	rm "${BUILD_DIR}/install$(python_get_sitedir)"/CifFile/drel/{parser.out,parsetab.py} || die
}
