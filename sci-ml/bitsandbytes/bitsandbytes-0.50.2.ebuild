# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
# Upstream uses scikit_build_core.setuptools.build_meta, not its native backend.
DISTUTILS_USE_PEP517=standalone
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..14} )
ROCM_VERSION=6.3

inherit distutils-r1 rocm

DESCRIPTION="k-bit quantization (QLoRA) and 8-bit optimizers for PyTorch"
HOMEPAGE="https://github.com/bitsandbytes-foundation/bitsandbytes"
SRC_URI="
	https://github.com/bitsandbytes-foundation/${PN}/archive/refs/tags/${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Default to CPU; USE=rocm includes this overlay's RDNA3/Strix Halo targets.
IUSE="rocm"

# The HIP extension links and uses these ROCm libraries at runtime. Upstream
# requires hipBLAS, hipRAND, and hipBLASLt; rocBLAS links transitively on Linux
# but remains a direct header/ABI dependency, so retain :=. # verified 2026-08-30
RDEPEND="
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/packaging[${PYTHON_USEDEP}]
	')
	rocm? (
		dev-util/hip:=
		sci-libs/hipBLAS:=
		sci-libs/hipBLASLt:=
		sci-libs/hipRAND:=
		sci-libs/rocBLAS:=
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	$(python_gen_cond_dep '
		dev-python/scikit-build-core[${PYTHON_USEDEP}]
		dev-python/setuptools[${PYTHON_USEDEP}]
		dev-python/trove-classifiers[${PYTHON_USEDEP}]
	')
"

src_compile() {
	# CMAKE_ARGS selects HIP and forwards targets to CMAKE_HIP_ARCHITECTURES.
	if use rocm; then
		export CMAKE_ARGS="-DCOMPUTE_BACKEND=hip -DAMDGPU_TARGETS=$(get_amdgpu_flags)"
	fi

	distutils-r1_src_compile
}
