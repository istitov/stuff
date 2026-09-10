# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=scikit-build-core
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

inherit cuda distutils-r1 pypi

DESCRIPTION="Tile-level programming language for high-performance ML kernels"
HOMEPAGE="
	https://github.com/tile-ai/tilelang
	https://pypi.org/project/tilelang/
"

LICENSE="Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 MIT public-domain"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+cuda rocm"
REQUIRED_USE="^^ ( cuda rocm )"
# The suite requires a supported GPU and JIT-compiles a large kernel matrix.
RESTRICT="test"

# Mirror upstream's Python <3.14 gate for torch-c-dlpack-ext.
# verified 2026-05-25
# Retain upstream's tvm-ffi >=0.1.10,<0.2 range; consumers may pin tighter.
RDEPEND="
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
	sci-mathematics/z3:=[python,${PYTHON_SINGLE_USEDEP}]
	cuda? (
		dev-util/nvidia-cuda-toolkit:=
		sci-ml/caffe2[cuda]
	)
	rocm? (
		dev-util/hip:=
		dev-util/hipcc:=
		sci-ml/caffe2[rocm]
	)
	$(python_gen_cond_dep '
		>=dev-python/apache-tvm-ffi-0.1.10[${PYTHON_USEDEP}]
		<dev-python/apache-tvm-ffi-0.2[${PYTHON_USEDEP}]
		dev-python/cloudpickle[${PYTHON_USEDEP}]
		dev-python/ml-dtypes[${PYTHON_USEDEP}]
		>=dev-python/numpy-1.23.5[${PYTHON_USEDEP}]
		dev-python/psutil[${PYTHON_USEDEP}]
		>=dev-python/tqdm-4.62.3[${PYTHON_USEDEP}]
		>=dev-python/typing-extensions-4.10[${PYTHON_USEDEP}]
	')
	python_single_target_python3_12? ( dev-python/torch-c-dlpack-ext[${PYTHON_SINGLE_USEDEP}] )
	python_single_target_python3_13? ( dev-python/torch-c-dlpack-ext[${PYTHON_SINGLE_USEDEP}] )
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-util/patchelf-0.17.2
	cuda? ( dev-util/nvidia-cuda-toolkit:= )
	$(python_gen_cond_dep '
		>=dev-python/cython-3.1[${PYTHON_USEDEP}]
	')
"

# Upstream caps z3-solver at <4.15.5, but Gentoo provides newer versions.
# Treat it as a tested-version cap unless an incompatibility surfaces. # verified 2026-08-05

# Upstream's Z3 finder searches wheel paths only. Preseed system paths so it
# creates z3::libz3 from the packaged library.
# Cython >=3.3 rejects upstream's cp38 limited API target; patch it to cp310,
# matching requires-python >=3.10. # verified 2026-08-31
PATCHES=( "${FILESDIR}/${P}-py-limited-api-310.patch" )

python_prepare_all() {
	# Load the platform before initializing imported CUDA targets.
	sed -e '\|include(${CMAKE_CURRENT_LIST_DIR}/cmake/FindPipCUDAToolkit.cmake)|d' \
		-e '/project(TILE_LANG C CXX)/a include(${CMAKE_CURRENT_LIST_DIR}/cmake/FindPipCUDAToolkit.cmake)' \
		-i CMakeLists.txt || die

	use cuda && cuda_src_prepare
	distutils-r1_python_prepare_all
}

python_configure_all() {
	export NO_VERSION_LABEL=ON

	DISTUTILS_ARGS+=(
		"-DUSE_CUDA=$(usex cuda ON OFF)"
		"-DUSE_ROCM=$(usex rocm "${ESYSROOT}"/usr OFF)"
		-DZ3_INCLUDE_DIR="${ESYSROOT}"/usr/include
		-DZ3_LIBRARY="${ESYSROOT}"/usr/$(get_libdir)/libz3.so
	)

	if use cuda; then
		local cuda_gcc_dir
		cuda_gcc_dir=$(cuda_gccdir)
		export CUDAHOSTCXX="${cuda_gcc_dir}"/g++
		DISTUTILS_ARGS+=( -DCMAKE_CUDA_HOST_COMPILER="${CUDAHOSTCXX}" )
	fi
}

DISTUTILS_ARGS=(
	-DTILELANG_USE_CUDA_STUBS=OFF
	-DTILELANG_USE_HIP_STUBS=OFF
	# Leave compiler caching to Portage FEATURES.
	-DCMAKE_C_COMPILER_LAUNCHER=
	-DCMAKE_CXX_COMPILER_LAUNCHER=
	-DCMAKE_CUDA_COMPILER_LAUNCHER=
)

python_install_all() {
	distutils-r1_python_install_all

	# Drop wheel-only paths while preserving tvm_ffi's nonstandard libdir.
	local so
	while IFS= read -r -d '' so; do
		patchelf --set-rpath \
			'$ORIGIN:$ORIGIN/../../tvm_ffi/lib' "${so}" || die
	done < <(find "${ED}" \( \
		-name 'libtvm_compiler.so' -o \
		-name 'libtvm_runtime.so' -o \
		-name 'libtilelang.so' \
	\) -print0)

	if use cuda; then
		# --as-needed drops the CUDA driver stub from DT_NEEDED even though
		# these libraries call driver API symbols at runtime.
		while IFS= read -r -d '' so; do
			patchelf --add-needed libcuda.so.1 "${so}" || die
		done < <(find "${ED}" \( \
			-name 'libtvm_runtime.so' -o \
			-name 'libtilelang.so' \
		\) -print0)
	fi
}

pkg_postinst() {
	use cuda || return

	local cuda_gcc_dir
	cuda_gcc_dir=$(cuda_gccdir)

	elog "tilelang JIT-compiles kernels with nvcc at runtime. If the active"
	elog "compiler is unsupported by CUDA, select the compatible compiler with:"
	elog ""
	elog "  export NVCC_PREPEND_FLAGS='-ccbin ${cuda_gcc_dir}/g++'"
}
