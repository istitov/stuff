# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 multiprocessing pypi

DESCRIPTION="The Blis BLAS-like linear algebra library, as a self-contained C-extension"
HOMEPAGE="
	https://github.com/explosion/cython-blis
	https://pypi.org/project/blis/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"

# This Python wrapper vendors BLIS for thinc; system sci-libs/blis is not a
# drop-in replacement for that pinned layer.

# Bundled BLIS 0.7.0 references KNL flags removed by GCC 16; deleting only its
# kernels leaves dispatch symbols unresolved. Use generic until upstream's
# vendored BLIS drops KNL, accepting reduced SIMD performance.
# verified 2026-10-26
RDEPEND="
	${PYTHON_DEPS}
	>=dev-python/numpy-1.21.2[${PYTHON_USEDEP}]
	<dev-python/numpy-3[${PYTHON_USEDEP}]
"
# setup.py imports NumPy to locate its headers; build against the NumPy 2
# API required by pyproject.toml. verified 2026-10-27
DEPEND="
	>=dev-python/numpy-2.0.0[${PYTHON_USEDEP}]
	<dev-python/numpy-3[${PYTHON_USEDEP}]
"
BDEPEND="
	${PYTHON_DEPS}
	>=dev-python/cython-3.1[${PYTHON_USEDEP}]
	<dev-python/cython-4[${PYTHON_USEDEP}]
	${DEPEND}
"

src_compile() {
	export BLIS_ARCH="generic"
	# Since 1.3.4 setup.py compiles BLIS objects in a thread pool sized by
	# MAX_JOBS, else by the CPU count; keep it to MAKEOPTS.
	# verified 2026-10-26
	export MAX_JOBS="$(makeopts_jobs)"
	distutils-r1_src_compile
}
