# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..13} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 cuda

DESCRIPTION="Differentiable antialiased Gaussian rasterization (mip-splatting) for TRELLIS"
HOMEPAGE="https://github.com/autonomousvision/mip-splatting"
# The antialiased diff-gaussian-rasterization that TRELLIS/mip-splatting use is a
# git submodule with a bundled glm and no cleanly pinnable upstream tag, so the
# self-contained source is vendored in the istitov/extra-stuff distfile repo
# (glm rides along).
SRC_URI="https://raw.githubusercontent.com/istitov/extra-stuff/${P}-r0-0/dev-python/${PN}/${P}.tar.xz -> ${P}-r0-0.tar.xz"
S="${WORKDIR}/${P}"

# Package code: Inria/MPII Gaussian-Splatting License (research/non-commercial).
# Bundled third_party/glm: MIT (Happy Bunny / MIT dual -> MIT).
LICENSE="Gaussian-Splatting MIT"
SLOT="0"
KEYWORDS="~amd64"
# Non-commercial license: do not mirror or redistribute binaries.
RESTRICT="bindist mirror"

RDEPEND="sci-ml/caffe2[${PYTHON_SINGLE_USEDEP}]"
DEPEND="${RDEPEND}"
BDEPEND="
	$(python_gen_cond_dep '
		dev-python/setuptools[${PYTHON_USEDEP}]
		dev-python/wheel[${PYTHON_USEDEP}]
	')
"

src_prepare() {
	distutils-r1_src_prepare
}

src_compile() {
	# torch cpp_extension reads CC/CXX for nvcc's -ccbin; pin to the
	# cuda-eclass gcc (<=15 for CUDA 13.x). Arch from make.conf (caffe2 convention).
	local gccdir
	gccdir=$(cuda_gccdir) || die
	export CC="${gccdir}/gcc" CXX="${gccdir}/g++"
	export TORCH_CUDA_ARCH_LIST="${TORCH_CUDA_ARCH_LIST:-8.0 8.6 8.9 9.0}"
	export FORCE_CUDA=1 MAX_JOBS="${MAX_JOBS:-4}"

	distutils-r1_src_compile
}
