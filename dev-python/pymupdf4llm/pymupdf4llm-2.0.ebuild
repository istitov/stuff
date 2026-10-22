# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit python-r1

DESCRIPTION="Convert PDF documents to Markdown for LLM and RAG applications"
HOMEPAGE="
	https://github.com/pymupdf/pymupdf4llm
	https://pymupdf.readthedocs.io/en/latest/pymupdf4llm/
	https://pypi.org/project/pymupdf4llm/
"
S="${WORKDIR}"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# From 2.0, dev-python/pymupdf ships the pymupdf4llm module; upstream's PyPI
# pymupdf4llm-2.0 is an empty transition wheel. verified 2026-10-22
RDEPEND="
	${PYTHON_DEPS}
	~dev-python/pymupdf-${PV}[${PYTHON_USEDEP}]
"
