# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
# Upstream drives the CMake build from setup.py's custom build_cmake via the
# scikit-build-core setuptools shim (build-backend =
# scikit_build_core.setuptools.build_meta, wheel.cmake=false). The CMakeLists
# has no install() rule; it emits libbitsandbytes_<backend>.so straight into
# the package dir (LIBRARY_OUTPUT_DIRECTORY) which setuptools then packages.
# So use the package's own PEP517 backend (standalone) rather than the
# eclass's scikit-build-core value (which expects scikit_build_core.build).
DISTUTILS_USE_PEP517=standalone
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{11..13} )
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
KEYWORDS="~amd64"

# Default backend is CPU; USE=rocm builds the HIP/ROCm backend. The ROCm
# gfx coverage includes the consumer RDNA3 (gfx1100) and Strix-Halo
# (gfx1150/gfx1151) targets this overlay uses.
IUSE="rocm"

RDEPEND="
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/packaging[${PYTHON_USEDEP}]
	')
"
DEPEND="${RDEPEND}"
BDEPEND="
	$(python_gen_cond_dep '
		dev-python/scikit-build-core[${PYTHON_USEDEP}]
		dev-python/setuptools[${PYTHON_USEDEP}]
		dev-python/trove-classifiers[${PYTHON_USEDEP}]
	')
	rocm? (
		dev-util/hip
		sci-libs/hipBLAS
		sci-libs/rocBLAS
	)
"

src_compile() {
	# COMPUTE_BACKEND defaults to cpu in the CMakeLists; select the HIP/ROCm
	# backend here. scikit-build-core honors the CMAKE_ARGS environment
	# variable, and bitsandbytes reads AMDGPU_TARGETS for CMAKE_HIP_ARCHITECTURES.
	if use rocm; then
		export CMAKE_ARGS="-DCOMPUTE_BACKEND=hip -DAMDGPU_TARGETS=$(get_amdgpu_flags)"
	fi

	distutils-r1_src_compile
}
