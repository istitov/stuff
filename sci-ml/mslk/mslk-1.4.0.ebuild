# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Meta Superintelligence Labs Kernels: GenAI operators for PyTorch"
HOMEPAGE="https://github.com/meta-pytorch/MSLK"
# PyPI carries only a 0.0.0 placeholder; upstream publishes wheels on the
# PyTorch index. verified 2026-11-14
SRC_URI="
	https://github.com/meta-pytorch/MSLK/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"
S="${WORKDIR}/MSLK-${PV}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# The tests need a GPU.
RESTRICT="test"

PATCHES=( "${FILESDIR}/${P}-python-only-no-flydsl.patch" )

# Upstream's python-only build compiles nothing and loads no native library.
# Attention dispatch then has, on CUDA, PyTorch's own memory-efficient
# (CUTLASS) kernel and FlashAttention from flash-attn or from a PyTorch built
# with it, and on both vendors the Triton split-K kernel; the Composable
# Kernel operators are gone. Upstream's compiled ROCm kernels target gfx942
# alone. Triton is imported only when available. verified 2026-11-15
# (sm_86, on a PyTorch with memefficient but no flash)
RDEPEND="
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
	')
"

python_compile() {
	local -x MSLK_PYTHON_ONLY=1
	local -x MSLK_VERSION_OVERRIDE=${PV}
	distutils-r1_python_compile
}
