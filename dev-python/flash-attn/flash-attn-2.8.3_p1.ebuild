# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..13} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 pypi cuda

# csrc/cutlass is a git submodule that the PyPI sdist does NOT bundle (the
# 8.4MB sdist carries only flash-attn's own kernels). Supply it as a second
# distfile pinned to the exact submodule commit recorded in v${PV}'s tree
# (== CUTLASS 4.0.0) and stage it into csrc/cutlass before the build.
CUTLASS_COMMIT="dc4817921edda44a549197ff3a9dcf5df0636e7b"

DESCRIPTION="Fast and memory-efficient exact attention (FlashAttention-2)"
HOMEPAGE="
	https://github.com/Dao-AILab/flash-attention
	https://pypi.org/project/flash-attn/
"
SRC_URI+="
	https://github.com/NVIDIA/cutlass/archive/${CUTLASS_COMMIT}.tar.gz
		-> flash-attn-cutlass-${CUTLASS_COMMIT:0:8}.gh.tar.gz
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	sci-ml/caffe2[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/einops[${PYTHON_USEDEP}]
		dev-python/packaging[${PYTHON_USEDEP}]
	')
"
DEPEND="${RDEPEND}"
BDEPEND="
	app-alternatives/ninja
	$(python_gen_cond_dep '
		dev-python/setuptools[${PYTHON_USEDEP}]
	')
"

src_prepare() {
	# Stage the pinned CUTLASS into the submodule path setup.py expects;
	# without it the build aborts at the csrc/cutlass/include/cutlass.h check.
	rmdir csrc/cutlass 2>/dev/null
	mv "${WORKDIR}/cutlass-${CUTLASS_COMMIT}" csrc/cutlass || die

	distutils-r1_src_prepare
}

src_compile() {
	local gccdir
	gccdir=$(cuda_gccdir) || die
	# torch's cpp_extension passes CC/CXX to nvcc as -ccbin; CUDA 13.x rejects
	# gcc>15, so pin the cuda-eclass gcc.
	export CC="${gccdir}/gcc" CXX="${gccdir}/g++"
	export TORCH_CUDA_ARCH_LIST="${TORCH_CUDA_ARCH_LIST:-8.0 8.6 8.9 9.0}"
	export FORCE_CUDA=1 FLASH_ATTENTION_FORCE_BUILD=TRUE
	# The flash_bwd_hdim128 kernels peak ~10-13GB each under cicc; at the
	# upstream default MAX_JOBS they OOM a 32GB host. Cap parallelism.
	export MAX_JOBS="${MAX_JOBS:-2}" NVCC_THREADS="${NVCC_THREADS:-2}"

	distutils-r1_src_compile
}
