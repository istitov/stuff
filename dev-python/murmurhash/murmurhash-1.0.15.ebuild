# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Cython bindings for MurmurHash2"
HOMEPAGE="
	https://github.com/explosion/murmurhash
	https://pypi.org/project/murmurhash/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# GitHub tags lag PyPI; Thinc requires MurmurHash <1.1.
RDEPEND="${PYTHON_DEPS}"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	dev-python/cython[${PYTHON_USEDEP}]
"
