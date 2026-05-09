# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=standalone
DISTUTILS_EXT=1

inherit toolchain-funcs distutils-r1

DESCRIPTION="A Python library for manipulation of PDF documents"
HOMEPAGE="
	https://github.com/pymupdf/pymupdf
	https://pymupdf.readthedocs.io
"
SRC_URI="https://github.com/pymupdf/${PN}/archive/${PV}.tar.gz
	-> ${P}.gh.tar.gz"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	dev-python/mupdf:=[${PYTHON_USEDEP}]
	dev-python/pymupdf-fonts[${PYTHON_USEDEP}]
	dev-python/pipcl[${PYTHON_USEDEP}]
"
RDEPEND="
	${DEPEND}
"
BDEPEND="
	dev-lang/swig
	test? (
		dev-python/flake8[${PYTHON_USEDEP}]
		dev-python/mypy[${PYTHON_USEDEP}]
		dev-python/pylint[${PYTHON_USEDEP}]
	)
"

PATCHES=( "${FILESDIR}"/tests.diff )

# Test deselects forked from ::4nykey 2026-05-09 — most are upstream
# regression tests for specific GitHub issue numbers (test_NNNN),
# others need OCR (tesseract), lint tools at test time (codespell,
# pylint), or test data not in distfile. Re-verify on PyMuPDF bumps.
EPYTEST_DESELECT=(
	tests/test_4505.py::test_4505
	tests/test_widgets.py::test_2391
	tests/test_widgets.py::test_3216
	tests/test_widgets.py::test_3950
	tests/test_widgets.py::test_4004
	tests/test_widgets.py::test_4055
	tests/test_widgets.py::test_4965
	tests/test_widgets.py::test_checkbox
	tests/test_widgets.py::test_interfield_calculation
	tests/test_widgets.py::test_text
	tests/test_codespell.py::test_codespell
	tests/test_font.py::test_4457
	tests/test_general.py::test_4533
	tests/test_general.py::test_4702
	tests/test_general.py::test_open2
	tests/test_memory.py::test_4751
	tests/test_pixmap.py::test_3050
	tests/test_pixmap.py::test_3058
	tests/test_pixmap.py::test_3854
	tests/test_pixmap.py::test_4445
	tests/test_pixmap.py::test_color_count
	tests/test_pylint.py::test_pylint
	tests/test_tesseract.py
	tests/test_textbox.py::test_textbox3
	tests/test_textextract.py::test_4180
)

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_compile() {
	# Use system app-text/mupdf via dev-python/mupdf for headers/lib;
	# don't let upstream setup.py rebuild MuPDF from a bundled copy.
	local _i=( $($(tc-getPKG_CONFIG) mupdf --cflags-only-I) )
	PYMUPDF_SETUP_FLAVOUR='p' \
	PYMUPDF_SETUP_MUPDF_BUILD= \
	PYMUPDF_SETUP_MUPDF_THIRD=0 \
	PYMUPDF_SETUP_MUPDF_REBUILD=0 \
	PYMUPDF_INCLUDES="$(printf '%s:' ${_i[@]//-I})${EPREFIX}/usr/include" \
	PYMUPDF_MUPDF_LIB="${EPREFIX}/usr" \
	LD="${CXX}" \
		distutils-r1_python_compile
}
