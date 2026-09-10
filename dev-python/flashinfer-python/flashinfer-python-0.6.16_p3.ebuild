# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=standalone
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 pypi

DESCRIPTION="FlashInfer: kernel library for LLM serving (Python frontend)"
HOMEPAGE="
	https://github.com/flashinfer-ai/flashinfer
	https://pypi.org/project/flashinfer-python/
"

LICENSE="Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD Boost-1.0 MIT NVIDIA-CUDA NVIDIA-SDK"
SLOT="0"
KEYWORDS="~amd64"
# JIT sources carry proprietary NVIDIA/TensorRT notices; tests are incomplete
# and meaningful checks require a CUDA device and nvcc.
RESTRICT="bindist mirror test"

# The pure-Python wheel installs CUDA and vendor sources JIT-compiled by nvcc;
# keep the runtime toolchain explicit. blk128 imports the quack-kernels module.
RDEPEND="
	app-alternatives/ninja
	dev-util/nvidia-cuda-toolkit:=
	dev-python/quack-kernels[${PYTHON_SINGLE_USEDEP}]
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
	sci-ml/caffe2[cuda,-rocm]
	sys-devel/gcc:*[cxx]
	$(python_gen_cond_dep '
		>=dev-python/apache-tvm-ffi-0.1.6[${PYTHON_USEDEP}]
		<dev-python/apache-tvm-ffi-0.2[${PYTHON_USEDEP}]
		dev-python/click[${PYTHON_USEDEP}]
		>=dev-python/cuda-python-12.0[${PYTHON_USEDEP}]
		>=dev-python/cuda-tile-bin-1.4.0[${PYTHON_USEDEP}]
		dev-python/einops[${PYTHON_USEDEP}]
		dev-python/filelock[${PYTHON_USEDEP}]
		dev-python/jinja2[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		>=dev-python/nvidia-cudnn-frontend-1.25.0[${PYTHON_USEDEP}]
		>=dev-python/nvidia-cutlass-dsl-4.5.0[${PYTHON_USEDEP}]
		dev-python/nvidia-ml-py[${PYTHON_USEDEP}]
		>=dev-python/packaging-24.2[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
		dev-python/tabulate[${PYTHON_USEDEP}]
		dev-python/tqdm[${PYTHON_USEDEP}]
		dev-python/typing-extensions[${PYTHON_USEDEP}]
		~dev-python/flashinfer-cubin-'${PV}'[${PYTHON_USEDEP}]
	')
"
BDEPEND="
	$(python_gen_cond_dep '
		>=dev-python/setuptools-77[${PYTHON_USEDEP}]
		>=dev-python/packaging-24[${PYTHON_USEDEP}]
		>=dev-python/apache-tvm-ffi-0.1.6[${PYTHON_USEDEP}]
		<dev-python/apache-tvm-ffi-0.2[${PYTHON_USEDEP}]
	')
"

src_prepare() {
	# Remove the unmatched license glob before setuptools makes it fatal.
	sed -e 's/\["LICENSE", "LICENSE\*\.txt"\]/["LICENSE"]/' \
		-i pyproject.toml || die

	# nccl4py is unpackaged and its backend is lazy; remove the false hard dep.
	grep -qx 'nccl4py>=0.3.1' requirements.txt || die
	sed -e '/^nccl4py>=0\.3\.1$/d' -i requirements.txt || die

	# Prevent PEP-517 from installing CUDA compiler wheels; use packaged tools.
	grep -q '^[[:space:]]*_install_cuda_tile_compile_deps()$' \
		build_backend.py || die
	sed -e '/^[[:space:]]*_install_cuda_tile_compile_deps()$/d' \
		-i build_backend.py || die

	# Namespace discovery over-includes vendor trees; retain only JIT-used paths.
	rm -rf \
		3rdparty/cccl/{benchmarks,ci,docs,python} \
		3rdparty/cccl/cub/benchmarks \
		3rdparty/cccl/libcudacxx/{codegen,test} \
		3rdparty/cccl/thrust/scripts \
		3rdparty/cutlass/{examples,python,test} \
		3rdparty/cutlass/tools/util/scripts \
		3rdparty/spdlog/scripts || die
	distutils-r1_src_prepare
}

src_compile() {
	# Disable unpackaged transport backends and their downloads/native builds.
	local -x BUILD_NVEP=0 BUILD_NCCL_EP=0 BUILD_NIXL_EP=0
	distutils-r1_src_compile
}

python_install_all() {
	distutils-r1_python_install_all

	# Remove PEP-517 helpers leaked into top-level site-packages; they also add a
	# false runtime setuptools dependency. verified 2026-05-07
	rm -f "${ED}"/usr/lib/python*/site-packages/build_backend.py || die
	rm -f "${ED}"/usr/lib/python*/site-packages/build_utils.py || die
	rm -rf "${ED}"/usr/lib/python*/site-packages/__pycache__/build_backend.* || die
	rm -rf "${ED}"/usr/lib/python*/site-packages/__pycache__/build_utils.* || die

	# Remove the same helpers duplicated in flashinfer.data.
	local data
	for data in "${ED}"/usr/lib/python*/site-packages/flashinfer/data; do
		[[ -d ${data} ]] || continue
		rm -rf "${data}"/__pycache__ || die
		rm -f "${data}"/{build_backend,build_utils}.py || die
	done
}

pkg_postinst() {
	elog "FlashInfer JIT-compiles missing GPU kernels with nvcc at runtime."
	elog "If the active compiler is newer than the installed CUDA toolkit"
	elog "supports, select a supported compiler with CC and CXX before"
	elog "starting the consuming application. FlashInfer passes CC to nvcc"
	elog "as its host compiler and uses CXX to compile and link host objects."
	elog "The cuTile backend additionally needs tileiras from CUDA Toolkit"
	elog "13.1 or newer."
	elog "The NCCL-EP and NIXL-EP transport backends are not packaged."
}
