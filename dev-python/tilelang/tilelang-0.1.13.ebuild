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

# torch-c-dlpack-ext is gated python_version<3.14 by upstream. Mirror
# that with python_targets_python3_{12..13} guards. # verified
# 2026-06-08 against 0.1.11.
#
# TileLang compiles TVM against tvm-ffi-0.1.11 and loads the separately
# installed Python package's library at runtime. Keep both ABIs exact.
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
		~dev-python/apache-tvm-ffi-0.1.11[${PYTHON_USEDEP}]
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
# Treat it as a tested-version cap unless an incompatibility surfaces.

# Upstream's bundled cmake/pypi-z3/FindZ3.cmake looks for libz3 and
# headers ONLY inside the PyPI z3-solver wheel's bundled site-packages
# layout (NO_DEFAULT_PATH). On Gentoo the system z3 lives in the target
# sysroot's standard include and ABI library directories. Pre-setting
# Z3_INCLUDE_DIR and Z3_LIBRARY makes CMake's find_path / find_library
# skip the lookup and create z3::libz3 with the correct paths.
python_prepare_all() {
	# Keep TVM's compiled FFI ABI aligned with the installed Python package.
	local tvm_ffi_dir="${ESYSROOT}$(python_get_sitedir)/tvm_ffi"
	[[ -f ${tvm_ffi_dir}/CMakeLists.txt ]] || die "system tvm_ffi sources not found"
	rm -r 3rdparty/tvm/3rdparty/tvm-ffi || die
	mkdir 3rdparty/tvm/3rdparty/tvm-ffi || die
	ln -s "${tvm_ffi_dir}"/{CMakeLists.txt,3rdparty,include,src} \
		3rdparty/tvm/3rdparty/tvm-ffi/ || die
	cp -a "${tvm_ffi_dir}"/share/cmake/tvm_ffi \
		3rdparty/tvm/3rdparty/tvm-ffi/cmake || die

	# CMake's imported CUDA targets are not initialized correctly before
	# project() has loaded the platform on Linux.
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
)

python_install_all() {
	distutils-r1_python_install_all

	# Drop wheel-only z3 and nvidia paths; keep the packaged libraries and
	# tvm_ffi's nonstandard library directory reachable.
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
