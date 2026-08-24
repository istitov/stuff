# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=standalone
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Convert PDF documents to Markdown for LLM and RAG applications"
HOMEPAGE="
	https://github.com/pymupdf/pymupdf4llm
	https://pymupdf.readthedocs.io/en/latest/pymupdf4llm/
	https://pypi.org/project/pymupdf4llm/
"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	~dev-python/PyMuPDF-${PV}[${PYTHON_USEDEP}]
	~dev-python/pymupdf-layout-bin-${PV}[${PYTHON_USEDEP}]
	dev-python/tabulate[${PYTHON_USEDEP}]
	dev-python/psutil[${PYTHON_USEDEP}]
"
BDEPEND="dev-python/pipcl[${PYTHON_USEDEP}]"

PATCHES=( "${FILESDIR}/${P}-sdist-no-git.patch" )

# Upstream does not declare the suite's test dependencies, and several tests
# exercise optional OCR engines and external lint tools.
RESTRICT="test"
