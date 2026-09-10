# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..13} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 pypi cuda

# PyPI omits csrc/cutlass; fetch the submodule commit recorded by v${PV}
# (CUTLASS 4.0.0) separately.
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
	>=dev-util/nvidia-cuda-toolkit-11.7:=
	sci-ml/caffe2[cuda,-rocm,${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/einops[${PYTHON_USEDEP}]
		dev-python/packaging[${PYTHON_USEDEP}]
	')
"
DEPEND="${RDEPEND}"
BDEPEND="
	app-alternatives/ninja
	$(python_gen_cond_dep '
		dev-python/psutil[${PYTHON_USEDEP}]
		dev-python/setuptools[${PYTHON_USEDEP}]
		dev-python/wheel[${PYTHON_USEDEP}]
	')
"

src_prepare() {
	# Populate the submodule path expected by setup.py.
	rmdir csrc/cutlass 2>/dev/null
	mv "${WORKDIR}/cutlass-${CUTLASS_COMMIT}" csrc/cutlass || die

	distutils-r1_src_prepare
}

src_compile() {
	local gccdir
	gccdir=$(cuda_gccdir) || die
	# Pin cpp_extension's nvcc host compiler to the CUDA-compatible GCC.
	export CC="${gccdir}/gcc" CXX="${gccdir}/g++"
	export FLASH_ATTN_CUDA_ARCHS="${FLASH_ATTN_CUDA_ARCHS:-80;90}"
	export FORCE_CUDA=1 FLASH_ATTENTION_FORCE_BUILD=TRUE
	# flash_bwd_hdim128 uses 10-13 GiB per cicc process; cap parallelism.
	export MAX_JOBS="${MAX_JOBS:-2}" NVCC_THREADS="${NVCC_THREADS:-2}"

	distutils-r1_src_compile
}
