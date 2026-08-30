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

inherit cuda distutils-r1 rocm

DESCRIPTION="k-bit quantization (QLoRA) and 8-bit optimizers for PyTorch"
HOMEPAGE="https://github.com/bitsandbytes-foundation/bitsandbytes"
SRC_URI="
	https://github.com/bitsandbytes-foundation/${PN}/archive/refs/tags/${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# Default backend is CPU; CUDA and ROCm backends are mutually exclusive.
IUSE="cuda rocm"
REQUIRED_USE="?? ( cuda rocm )"

# The ROCm atoms are RDEPEND, not BDEPEND: with USE=rocm the built extension
# links them and calls them at runtime. Declared only as BDEPEND they were
# invisible to the installed package, so depclean was free to unmerge the
# stack out from under it. Mirrors the cuda? atom.
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
# verified 2026-08-30 against the 0.50.0 source
RDEPEND="
	>=sci-ml/pytorch-2.4[${PYTHON_SINGLE_USEDEP}]
	<sci-ml/pytorch-3[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		>=dev-python/numpy-1.17[${PYTHON_USEDEP}]
		>=dev-python/packaging-20.9[${PYTHON_USEDEP}]
	')
	cuda? ( dev-util/nvidia-cuda-toolkit:= )
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
		>=dev-python/setuptools-77.0.3[${PYTHON_USEDEP}]
		>=dev-python/trove-classifiers-2025.8.6.13[${PYTHON_USEDEP}]
	')
"

src_prepare() {
	distutils-r1_src_prepare
	use cuda && cuda_src_prepare
}

src_compile() {
	# COMPUTE_BACKEND defaults to cpu in the CMakeLists. scikit-build-core
	# honors CMAKE_ARGS; bitsandbytes reads AMDGPU_TARGETS for
	# CMAKE_HIP_ARCHITECTURES.
	local cmake_args=()
	if use cuda; then
		local gccdir target capability
		local cuda_targets=()
		gccdir=$(cuda_gccdir) || die
		export CC="${gccdir}/gcc" CXX="${gccdir}/g++"
		cmake_args+=(
			-DCOMPUTE_BACKEND=cuda
			"-DCMAKE_CUDA_HOST_COMPILER=${gccdir}/g++"
		)

		if [[ -n ${NVPTX_TARGETS} ]]; then
			for target in ${NVPTX_TARGETS}; do
				cuda_targets+=( "${target#sm_}" )
			done
		elif [[ -n ${CUDAARCHS} ]]; then
			for target in ${CUDAARCHS//[;,]/ }; do
				target=${target#sm_}
				cuda_targets+=( "${target//./}" )
			done
		fi

		if [[ ${#cuda_targets[@]} -gt 0 ]]; then
			capability=$(IFS=';'; printf '%s' "${cuda_targets[*]}")
			cmake_args+=( "-DCOMPUTE_CAPABILITY=${capability}" )
		fi
	elif use rocm; then
		cmake_args+=(
			-DCOMPUTE_BACKEND=hip
			"-DAMDGPU_TARGETS=$(get_amdgpu_flags)"
		)
	fi
	export CMAKE_ARGS="${CMAKE_ARGS} ${cmake_args[*]}"

	distutils-r1_src_compile
}
