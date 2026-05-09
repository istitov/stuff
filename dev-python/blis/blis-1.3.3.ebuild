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

# verified 2026-05-09: bundled BLIS 0.7.0 build instructions in
# linux-x86_64.jsonl include Knights Landing (KNL) kernels that
# require -mavx512pf and -march=knl. Both flags were removed in
# gcc-16 (KNL was deprecated by Intel in 2017). Strip those kernel
# entries in src_prepare; their absence is harmless because BLIS
# does runtime CPU dispatch and KNL CPUs are end-of-life.
RDEPEND="
	${PYTHON_DEPS}
	dev-python/numpy[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	dev-python/cython[${PYTHON_USEDEP}]
"

src_prepare() {
	# Strip every jsonl entry that targets KNL (Knights Landing) —
	# either compiles a kernels/knl/ source file, or builds a _knl_
	# ref-kernel variant. See comment above RDEPEND.
	sed -i \
		-e '/"-march=knl"/d' \
		-e '/"kernels\/knl/d' \
		blis/_src/make/linux-x86_64.jsonl || die
	# A few SKX-targeted ref kernels still pass -mno-avx512pf /
	# -mno-avx512er to suppress KNL extensions they don't use; gcc-16
	# rejects those flags too. Drop them in place.
	sed -i \
		-e 's/, "-mno-avx512pf"//g' \
		-e 's/, "-mno-avx512er"//g' \
		blis/_src/make/linux-x86_64.jsonl || die
	distutils-r1_src_prepare
}
