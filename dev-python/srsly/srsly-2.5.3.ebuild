# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Modern high-performance serialization utilities for Python"
HOMEPAGE="
	https://github.com/explosion/srsly
	https://pypi.org/project/srsly/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# spaCy and Thinc cap Srsly below 3. PyPI is canonical after GitHub 2.4.8,
# whose Python 2 Cython code fails with Cython 3. verified 2026-05-09
RDEPEND="
	${PYTHON_DEPS}
	dev-python/catalogue[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	dev-python/cython[${PYTHON_USEDEP}]
"
