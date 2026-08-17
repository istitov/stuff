# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..13} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 cuda

DESCRIPTION="Voxel <-> space-filling-curve (Morton/Hilbert) sequence CUDA ops for TRELLIS"
HOMEPAGE="https://github.com/microsoft/TRELLIS"
# A TRELLIS-local extension (extensions/vox2seq) that upstream later removed from
# the repo; sourced from the if-ai/ComfyUI-IF_Trellis bundle and vendored on
# the istitov/extra-stuff distfile repo. MIT (TRELLIS).
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
	# Build only for the GPU(s) actually present. An explicit
	# TORCH_CUDA_ARCH_LIST (e.g. from make.conf) always wins; otherwise
	# probe the native compute capability with nvcc's device query
	# (e.g. 86 -> 8.6) so each host compiles just what it can run. If no
	# GPU is visible at build time (headless / binhost), leave it unset
	# and let torch's cpp_extension fall back to its full arch list.
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
