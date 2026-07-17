# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="Create, read, and update Microsoft PowerPoint (.pptx) files"
HOMEPAGE="
	https://github.com/scanny/python-pptx
	https://pypi.org/project/python-pptx/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/lxml-3.1.0[${PYTHON_USEDEP}]
	>=dev-python/pillow-3.3.2[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.9.0[${PYTHON_USEDEP}]
	>=dev-python/xlsxwriter-0.5.7[${PYTHON_USEDEP}]
"

# tests/unitutil/cxml.py builds the XML fixtures with pyparsing (same test
# helper as python-docx); most of the suite imports it during collection.
BDEPEND="
	test? (
		dev-python/pyparsing[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest
