# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..13} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 cuda

DESCRIPTION="Differentiable antialiased Gaussian rasterization (mip-splatting) for TRELLIS"
HOMEPAGE="https://github.com/autonomousvision/mip-splatting"
# Pin the untagged submodule and bundled GLM through extra-stuff.
SRC_URI="https://raw.githubusercontent.com/istitov/extra-stuff/${P}-r0-0/dev-python/${PN}/${P}.tar.xz -> ${P}-r0-0.tar.xz"
S="${WORKDIR}/${P}"

# Package code is research-only; bundled GLM is MIT.
LICENSE="Gaussian-Splatting MIT"
SLOT="0"
KEYWORDS="~amd64"
# The non-commercial license forbids binary redistribution.
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
	# cpp_extension uses CC/CXX as nvcc's host compiler; select cuda.eclass GCC.
	local gccdir
	gccdir=$(cuda_gccdir) || die
	export CC="${gccdir}/gcc" CXX="${gccdir}/g++"
	# Respect explicit targets; otherwise probe the native GPU. Headless builds
	# leave the variable unset and use cpp_extension's fallback list.
	if [[ -z ${TORCH_CUDA_ARCH_LIST} ]]; then
		cuda_add_sandbox -w
		local native_cc
		native_cc=$(__nvcc_device_query 2>/dev/null)
		[[ ${native_cc} =~ ^[0-9]{2,}$ ]] &&
			export TORCH_CUDA_ARCH_LIST="${native_cc%?}.${native_cc: -1}"
	fi
	export FORCE_CUDA=1 MAX_JOBS="${MAX_JOBS:-4}"

	distutils-r1_src_compile
}
