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
KEYWORDS="~amd64"

# This is the Python wrapper from explosion/cython-blis (different
# from sci-libs/blis which is the C library on its own). Upstream
# bundles its own copy of the BLIS sources and builds them at install
# time — that's the explicit ExplosionAI design choice for thinc's
# performance story; system sci-libs/blis isn't a drop-in (different
# vendoring layer + version pinning).

# verified 2026-05-09: bundled BLIS 0.7.0's linux-x86_64.jsonl build
# rules trip gcc-16 because they reference Knights Landing (KNL)
# flags removed from modern gcc (-march=knl, -mavx512pf, -mavx512er;
# Intel deprecated KNL in 2017). Stripping the KNL kernel entries
# isn't enough — the dispatch table hard-references KNL symbols, so
# the link succeeds but runtime imports fail with "undefined symbol:
# bli_cgemmsup_c_knl_ref". Force BLIS_ARCH=generic instead, which
# selects linux-generic.jsonl (298 lines, no KNL anywhere). Loses
# SIMD perf relative to the SKX kernels — see Layer 3 ebuild bump
# todo for a sustainable fix (track upstream cython-blis bumps to
# vendored BLIS that drop KNL outright).
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
	# Force generic kernel set — see comment above RDEPEND for why.
	export BLIS_ARCH="generic"
	distutils-r1_src_compile
}
