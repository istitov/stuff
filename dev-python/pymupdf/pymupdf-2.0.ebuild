# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=standalone
DISTUTILS_EXT=1

inherit toolchain-funcs distutils-r1 optfeature

# The GitHub repository and its archive directory keep upstream's casing.
MY_P="PyMuPDF-${PV}"
DESCRIPTION="A Python library for manipulation of PDF documents"
HOMEPAGE="
	https://github.com/pymupdf/pymupdf
	https://pymupdf.readthedocs.io
"
# 2.0 folds pymupdf_layout and pymupdf4llm into this package; upstream's
# PyPI releases of those two are now empty transition wheels. Build all three
# from their release tags, as upstream's pymupdf wheel does. verified 2026-10-22
LAYOUT_P="pymupdf_layout-${PV}"
LLM_P="pymupdf4llm-${PV}"
SRC_URI="
	https://github.com/pymupdf/PyMuPDF/archive/${PV}.tar.gz
		-> ${MY_P}.gh.tar.gz
	https://github.com/ArtifexSoftware/pymupdf_layout/archive/refs/tags/${PV}.tar.gz
		-> ${LAYOUT_P}.gh.tar.gz
	https://github.com/pymupdf/pymupdf4llm/archive/refs/tags/${PV}.tar.gz
		-> ${LLM_P}.gh.tar.gz
"
S="${WORKDIR}/${MY_P}"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

DEPEND="
	dev-python/mupdf:=[${PYTHON_USEDEP}]
	dev-python/pymupdf-fonts[${PYTHON_USEDEP}]
"
# Layout and 4llm runtime requirements, from setup.py's requires_dist with
# both embedded. verified 2026-10-22
RDEPEND="
	${DEPEND}
	dev-python/networkx[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/psutil[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	dev-python/tabulate[${PYTHON_USEDEP}]
	sci-libs/onnxruntime[python,${PYTHON_USEDEP}]
	!<dev-python/pymupdf4llm-2.0
	!<dev-python/pymupdf-layout-bin-2.0
"
BDEPEND="
	dev-lang/swig
	dev-python/pipcl[${PYTHON_USEDEP}]
	virtual/pkgconfig
	test? (
		dev-python/flake8[${PYTHON_USEDEP}]
		dev-python/mypy[${PYTHON_USEDEP}]
		dev-python/pylint[${PYTHON_USEDEP}]
	)
"

PATCHES=(
	"${FILESDIR}"/pymupdf-layout-4llm-no-git.patch
	"${FILESDIR}"/pymupdf-no-transition-requires.patch
)

# Deselect tests that need the network (pip installs), codespell or Tesseract,
# MuPDF barcode support, or that hit environment-specific layout and font
# behaviour. Re-derived against 2.0 from a full run: the 1.28.2 widget, pixmap,
# memory and textbox deselects now pass and were removed. verified 2026-10-22
EPYTEST_DESELECT=(
	tests/test_barcode.py::test_barcode
	tests/test_codespell.py::test_codespell
	"tests/test_docs_samples.py::test_docs_samples[docs/samples/code-printer.py]"
	tests/test_font.py::test_4457
	tests/test_general.py::test_4533
	tests/test_general.py::test_4702
	tests/test_general.py::test_open2
	tests/test_pixmap.py::test_4445
	tests/test_pixmap.py::test_5082
	tests/test_tesseract.py
)

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_compile() {
	# Build against system MuPDF instead of upstream's bundled copy.
	local _i=( $($(tc-getPKG_CONFIG) mupdf --cflags-only-I) )
	PYMUPDF_SETUP_PATH_LAYOUT="${WORKDIR}/${LAYOUT_P}" \
	PYMUPDF_SETUP_PATH_4LLM="${WORKDIR}/${LLM_P}" \
	PYMUPDF_SETUP_REQUIRE_LAYOUT_4LLM=0 \
	PYMUPDF_SETUP_MUPDF_BUILD= \
	PYMUPDF_SETUP_MUPDF_THIRD=0 \
	PYMUPDF_SETUP_MUPDF_REBUILD=0 \
	PYMUPDF_INCLUDES="$(printf '%s:' ${_i[@]//-I})${EPREFIX}/usr/include" \
	PYMUPDF_MUPDF_LIB="${EPREFIX}/usr" \
	LD="${CXX}" \
		distutils-r1_python_compile
}

python_test() {
	# Keep conftest.py from pip-installing its test requirements.
	local -x PYMUPDF_SYSINSTALL_ROOT=-
	epytest
}

pkg_postinst() {
	optfeature "OpenCV-based image and table-grid analysis in the layout module" \
		media-libs/opencv[python]
	optfeature "progress bars in pymupdf4llm" dev-python/tqdm
}
