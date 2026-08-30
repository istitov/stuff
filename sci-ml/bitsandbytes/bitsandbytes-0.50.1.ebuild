# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
# Upstream's build-backend is scikit_build_core.setuptools.build_meta (a
# setuptools shim that drives CMake; wheel.cmake=false), not
# scikit_build_core.build -- so use standalone, not the eclass's
# scikit-build-core value.
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
KEYWORDS="~amd64"

# Default backend is CPU; USE=rocm builds the HIP/ROCm backend. The ROCm
# gfx coverage includes the consumer RDNA3 (gfx1100) and Strix-Halo
# (gfx1150/gfx1151) targets this overlay uses.
IUSE="rocm"

# The ROCm atoms are RDEPEND, not BDEPEND: with USE=rocm the built extension
# links them and calls them at runtime. Declared only as BDEPEND they were
# invisible to the installed package, so depclean was free to unmerge the
# stack out from under it.
#
# The list is what upstream's CMakeLists.txt requires under BUILD_HIP, read
# from the unpacked source rather than inferred:
#   hipBLAS    find_package(hipblas REQUIRED), links roc::hipblas
#   hipRAND    find_package(hiprand REQUIRED), links hip::hiprand
#   hipBLASLt  find_package(hipblaslt), links roc::hipblaslt -- taken whenever
#              `hipconfig --version` reports HIP >= 6.1, so always here: ROCm
#              10.0 reports 7.15. The <6.1 branch only defines NO_HIPBLASLT.
#   rocBLAS    linked explicitly on WIN32 only; on Linux it arrives
#              transitively through roc::hipblas. Kept regardless, because
#              csrc/ops.cuh declares rocblas_handle members -- its headers and
#              ABI are a real dependency, so := must still fire on a rocBLAS
#              subslot flip.
# verified 2026-08-30 against the 0.50.2 source
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
	# COMPUTE_BACKEND defaults to cpu in the CMakeLists. scikit-build-core
	# honors CMAKE_ARGS; bitsandbytes reads AMDGPU_TARGETS for
	# CMAKE_HIP_ARCHITECTURES.
	if use rocm; then
		export CMAKE_ARGS="-DCOMPUTE_BACKEND=hip -DAMDGPU_TARGETS=$(get_amdgpu_flags)"
	fi

	distutils-r1_src_compile
}
