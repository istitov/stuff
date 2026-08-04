# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
LLVM_COMPAT=( 22 )

inherit cmake distutils-r1 git-r3 llvm-r2

DESCRIPTION="Python wrapper around the LLVM C++ library"
HOMEPAGE="https://llvmlite.pydata.org/
	https://github.com/numba/llvmlite"
EGIT_REPO_URI="https://github.com/numba/llvmlite.git"

LICENSE="BSD-2 Apache-2.0-with-LLVM-exceptions"
# Subslot tracks the (single) LLVM major llvmlite builds against -- the
# binding's ABI axis -- so a numba llvmlite:= dep rebuilds on an LLVM bump.
SLOT="0/${LLVM_COMPAT[0]}"
KEYWORDS=""

RDEPEND="$(llvm_gen_dep 'llvm-core/llvm:${LLVM_SLOT}=')"
DEPEND="${RDEPEND}"

distutils_enable_tests unittest

python_compile() {
	LLVMLITE_SHARED=ON \
		LLVM_CONFIG="$(get_llvm_prefix)/bin/llvm-config" \
		distutils-r1_python_compile
}

python_test() {
	LD_LIBRARY_PATH="$(get_llvm_prefix)/$(get_libdir)" \
		"${EPYTHON}" runtests.py -v || die "tests failed for ${EPYTHON}"
}
