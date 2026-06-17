# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..13} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 cuda

DESCRIPTION="Modular primitives for high-performance differentiable rendering"
HOMEPAGE="https://github.com/NVlabs/nvdiffrast"
SRC_URI="https://github.com/NVlabs/nvdiffrast/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="NVIDIA-nvdiffrast"
SLOT="0"
KEYWORDS="~amd64"
# NVIDIA Source Code License (non-commercial): no mirroring / binary redist.
RESTRICT="bindist mirror"

# nvdiffrast 0.4.0 compiles its CUDA ops (_nvdiffrast_c) at build time via
# torch's cpp_extension (older versions JIT'd at first use). torch reads CC/CXX
# for nvcc's -ccbin, so pin them to the cuda-eclass gcc (<=15 for CUDA 13.x).
# ninja stays a runtime dep for the GL-context plugin nvdiffrast still JITs.
RDEPEND="
	sci-ml/caffe2[${PYTHON_SINGLE_USEDEP}]
	app-alternatives/ninja
	$(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
	')
"
DEPEND="${RDEPEND}"
BDEPEND="
	$(python_gen_cond_dep '
		dev-python/setuptools[${PYTHON_USEDEP}]
	')
"

src_prepare() {
	distutils-r1_src_prepare
}

src_compile() {
	local gccdir
	gccdir=$(cuda_gccdir) || die
	export CC="${gccdir}/gcc" CXX="${gccdir}/g++"
	export TORCH_CUDA_ARCH_LIST="${TORCH_CUDA_ARCH_LIST:-8.0 8.6 8.9 9.0}"
	export FORCE_CUDA=1 MAX_JOBS="${MAX_JOBS:-4}"

	distutils-r1_src_compile
}
