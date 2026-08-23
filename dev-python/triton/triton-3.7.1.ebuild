# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1

LLVM_REV="1f126a6d"

DESCRIPTION="Language and compiler for custom deep-learning primitives"
HOMEPAGE="https://github.com/triton-lang/triton"
SRC_URI="https://github.com/triton-lang/triton/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.gh.tar.gz
	https://oaitriton.blob.core.windows.net/public/llvm-builds/llvm-${LLVM_REV}-ubuntu-x64-1.tar.gz
	-> ${P}.llvm.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# The upstream suite requires supported NVIDIA or AMD accelerator hardware.
RESTRICT="test"

BDEPEND="
	dev-build/cmake
	dev-build/ninja
	dev-python/pybind11[${PYTHON_USEDEP}]
"

# Use upstream's pinned LLVM toolchain and forbid setup.py's network downloads.
export TRITON_OFFLINE_BUILD=1
export TRITON_BUILD_PROTON=OFF

src_unpack() {
	unpack "${P}.gh.tar.gz"
	mkdir "${WORKDIR}/llvm" || die
	cd "${WORKDIR}/llvm" || die
	unpack "${P}.llvm.tar.gz"
}

python_compile() {
	local -x LLVM_SYSPATH="${WORKDIR}/llvm/llvm-${LLVM_REV}-ubuntu-x64-1"
	# Several LLVM translation units need multiple GiB each and can OOM with
	# common MAKEOPTS values.  Match the overlay's other large ML builds.
	local -x MAX_JOBS="${MAX_JOBS:-4}"
	distutils-r1_python_compile
}

python_install() {
	distutils-r1_python_install
	rm -r "${D}$(python_get_sitedir)/triton/plugins" || die
	rm "${D}$(python_get_sitedir)/triton/instrumentation/libGPUInstrumentationTestLib.so" || die
}
