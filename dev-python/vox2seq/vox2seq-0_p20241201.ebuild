# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 cuda

DESCRIPTION="Voxel <-> space-filling-curve (Morton/Hilbert) sequence CUDA ops for TRELLIS"
HOMEPAGE="https://github.com/microsoft/TRELLIS"
# TRELLIS removed this local extension; use the copy vendored from
# ComfyUI-IF_Trellis in extra-stuff.
SRC_URI="https://raw.githubusercontent.com/istitov/extra-stuff/${P}-r0-0/dev-python/${PN}/${P}.tar.xz -> ${P}-r0-0.tar.xz"
S="${WORKDIR}/${P}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror"

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
	local gccdir
	gccdir=$(cuda_gccdir) || die
	export CC="${gccdir}/gcc" CXX="${gccdir}/g++"
	# Respect TORCH_CUDA_ARCH_LIST; otherwise target the visible GPU.
	if [[ -z ${TORCH_CUDA_ARCH_LIST} ]]; then
		cuda_add_sandbox -w
		local native_cc
		native_cc=$(__nvcc_device_query 2>/dev/null)
		if [[ ${native_cc} =~ ^[0-9]{2,}$ ]]; then
			export TORCH_CUDA_ARCH_LIST="${native_cc%?}.${native_cc: -1}"
		else
			# Leaving it unset is not an option: with no device to query, torch
			# 2.13's cpp_extension collects an empty architecture list and then
			# indexes it, so the build dies with IndexError. PTX comes along
			# because this path serves builds that run elsewhere, and a 7.5 cubin
			# alone would not load on a newer GPU. verified 2026-09-16
			ewarn "No GPU is visible and TORCH_CUDA_ARCH_LIST is unset; building"
			ewarn "for compute capability 7.5 plus PTX, so the driver can JIT for"
			ewarn "a newer GPU. Set TORCH_CUDA_ARCH_LIST through Portage's"
			ewarn "package.env to target yours, then re-emerge ${PN}."
			export TORCH_CUDA_ARCH_LIST="7.5+PTX"
		fi
	fi
	export FORCE_CUDA=1 MAX_JOBS="${MAX_JOBS:-4}"

	distutils-r1_src_compile
}
