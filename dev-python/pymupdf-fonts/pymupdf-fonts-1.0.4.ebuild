# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1

DESCRIPTION="Collection of optional fonts for PyMuPDF"
HOMEPAGE="
	https://github.com/pymupdf/pymupdf-fonts
	https://pymupdf.readthedocs.io
"
SRC_URI="https://github.com/pymupdf/${PN}/archive/${PV}.tar.gz
	-> ${P}.gh.tar.gz"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
