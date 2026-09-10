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

# Prebuilt LLVM is installed statically in libtriton.so and as FileCheck; the
# AMD backend also installs UoI-NCSA HSA headers. All license terms are
# cumulative. # verified 2026-09-09 against the staged image
LICENSE="MIT Apache-2.0-with-LLVM-exceptions UoI-NCSA"
SLOT="0"
KEYWORDS="~amd64"

# The upstream suite requires supported NVIDIA or AMD accelerator hardware.
RESTRICT="test"

# Offline mode omits NVIDIA tools, and Triton has no PATH fallback. Without the
# installed toolkit symlinks, the first CUDA JIT fails to find ptxas.
# verified 2026-09-09 against the staged image and knobs.py:193-217
RDEPEND="
	!!dev-python/triton-bin
	dev-util/nvidia-cuda-toolkit
"
BDEPEND="
	dev-build/cmake
	dev-build/ninja
	dev-python/pybind11[${PYTHON_USEDEP}]
"

# Use upstream's pinned LLVM and forbid setup.py downloads.
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
	# LLVM translation units use multiple GiB each; cap default concurrency.
	local -x MAX_JOBS="${MAX_JOBS:-4}"
	distutils-r1_python_compile
}

python_install() {
	distutils-r1_python_install
	rm -r "${D}$(python_get_sitedir)/triton/plugins" || die
	rm "${D}$(python_get_sitedir)/triton/instrumentation/libGPUInstrumentationTestLib.so" || die

	# Link toolkit tools into Triton's lookup path. ptxas-blackwell has no toolkit
	# counterpart, so sm_100+ needs TRITON_PTXAS_BLACKWELL_PATH.
	# Strip EPREFIX because dodir/dosym add it themselves.
	local tool bindir="$(python_get_sitedir)"
	bindir="${bindir#"${EPREFIX}"}/triton/backends/nvidia/bin"
	dodir "${bindir}"
	for tool in ptxas cuobjdump nvdisasm; do
		dosym -r "/opt/cuda/bin/${tool}" "${bindir}/${tool}"
	done
}
