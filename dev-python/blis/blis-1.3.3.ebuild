# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="The Blis BLAS-like linear algebra library, as a self-contained C-extension"
HOMEPAGE="
	https://github.com/explosion/cython-blis
	https://pypi.org/project/blis/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# This Python wrapper vendors BLIS for thinc; system sci-libs/blis is not a
# drop-in replacement for that pinned layer.

# Bundled BLIS 0.7.0 references KNL flags removed by GCC 16; deleting only its
# kernels leaves dispatch symbols unresolved. Use generic until upstream's
# vendored BLIS drops KNL, accepting reduced SIMD performance.
# verified 2026-05-09
RDEPEND="
	${PYTHON_DEPS}
	dev-python/numpy[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	dev-python/cython[${PYTHON_USEDEP}]
"

src_compile() {
	export BLIS_ARCH="generic"
	distutils-r1_src_compile
}
