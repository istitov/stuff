# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
LLVM_COMPAT=( 20 )

inherit cmake distutils-r1 llvm-r2

DESCRIPTION="Python wrapper around the LLVM C++ library"
HOMEPAGE="https://llvmlite.pydata.org/
	https://github.com/numba/llvmlite"
SRC_URI="https://github.com/numba/llvmlite/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="BSD-2 Apache-2.0-with-LLVM-exceptions"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

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
