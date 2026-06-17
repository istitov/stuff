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
# extra-stuff. MIT (TRELLIS). See CLAUDE.md "Sister repo: extra-stuff".
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
	export TORCH_CUDA_ARCH_LIST="${TORCH_CUDA_ARCH_LIST:-8.0 8.6 8.9 9.0}"
	export FORCE_CUDA=1 MAX_JOBS="${MAX_JOBS:-4}"

	distutils-r1_src_compile
}
