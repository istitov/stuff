# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Cython memory pool for RAII-style memory management"
HOMEPAGE="
	https://github.com/explosion/cymem
	https://pypi.org/project/cymem/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# GitHub tags lag PyPI; spaCy/Thinc require Cymem <2.1.
RDEPEND="${PYTHON_DEPS}"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	dev-python/cython[${PYTHON_USEDEP}]
"
