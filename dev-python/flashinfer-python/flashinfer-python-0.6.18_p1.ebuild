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
# Required JIT sources carry NVIDIA proprietary and TensorRT source-code
# notices.  The sdist's two test modules are not a complete standalone suite,
# and meaningful JIT checks require a CUDA device and nvcc.
RESTRICT="bindist mirror test"

# The wheel build itself is pure Python, but the installed CUDA sources and
# vendored CUTLASS, spdlog and CCCL headers are compiled with nvcc on demand.
# Keep the runtime JIT self-contained rather than relying on an undeclared
# user-provided CUDA toolchain.
# The new blk128 sparse backend imports quack directly; its distribution name
# is quack-kernels (still `import quack` in
# flashinfer/cute_dsl/sparse/sm100_blk128/__init__.py at 0.6.18, and still
# absent from requirements.txt).
#
# 0.6.18 raised the nvidia-cutlass-dsl floor 4.5.0 -> 4.6.2a0; ::stuff carries
# 4.6.2 through 4.7.1, so the plain 4.6.2 floor covers the alpha bound.
# Upstream also excludes apache-tvm-ffi 0.1.8/0.1.8.post0 -- unreachable here,
# since the oldest apache-tvm-ffi in ::stuff is 0.1.11.
# verified 2026-08-29 against the 0.6.18 sdist requirements.txt, re-verified
# 2026-09-05 against the 0.6.18.post1 sdist -- the declared dep set is
# unchanged, including the exact `nccl4py>=0.3.1` line the src_prepare guard
# asserts before stripping it.
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
		>=dev-python/nvidia-cutlass-dsl-4.6.2[${PYTHON_USEDEP}]
		dev-python/nvidia-ml-py[${PYTHON_USEDEP}]
		>=dev-python/packaging-24.2[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
		dev-python/tabulate[${PYTHON_USEDEP}]
		dev-python/tqdm[${PYTHON_USEDEP}]
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
	# The sdist only contains LICENSE; setuptools warns that the second glob
	# matches nothing and will reject it once the deprecation becomes an error.
	sed -e 's/\["LICENSE", "LICENSE\*\.txt"\]/["LICENSE"]/' \
		-i pyproject.toml || die

	# nccl4py is not packaged.  Its nccl.ep backend is probed lazily and raises
	# a dedicated error when unavailable, so do not leave a false mandatory
	# requirement in the installed wheel metadata.
	grep -qx 'nccl4py>=0.3.1' requirements.txt || die
	sed -e '/^nccl4py>=0\.3\.1$/d' -i requirements.txt || die

	# The PEP-517 backend tries to install five CUDA compiler wheels with uv or
	# pip.  Package-manager builds must not mutate their environment or access
	# PyPI; use the packaged cuda-tile API and system CUDA compiler instead.
	grep -q '^[[:space:]]*_install_cuda_tile_compile_deps()$' \
		build_backend.py || die
	sed -e '/^[[:space:]]*_install_cuda_tile_compile_deps()$/d' \
		-i build_backend.py || die

	# setuptools discovers mapped vendor directories as namespace packages,
	# pulling in much more than pyproject.toml's declared header subsets.  Drop
	# examples, tests, CI/docs and Python tooling before the wheel is built,
	# while preserving every directory referenced by flashinfer.jit.env.
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
	# Upstream enables NCCL-EP and a native NIXL-EP build by default.  Neither
	# backend is packaged here; explicitly use the supported opt-out so the
	# build cannot install wheels, fetch submodules or compile NIXL implicitly.
	local -x BUILD_NVEP=0 BUILD_NCCL_EP=0 BUILD_NIXL_EP=0
	distutils-r1_src_compile
}

python_install_all() {
	distutils-r1_python_install_all

	# Upstream's [tool.setuptools] py-modules = ["build_backend",
	# "build_utils"] would leak both PEP-517 backend wrappers into
	# top-level site-packages, polluting the global namespace and
	# pulling setuptools into runtime. Same shape as the
	# dev-python/torch-c-dlpack-ext fix; drop both in install_all.
	# verified 2026-05-07 against 0.6.8.post1.
	rm -f "${ED}"/usr/lib/python*/site-packages/build_backend.py || die
	rm -f "${ED}"/usr/lib/python*/site-packages/build_utils.py || die
	rm -rf "${ED}"/usr/lib/python*/site-packages/__pycache__/build_backend.* || die
	rm -rf "${ED}"/usr/lib/python*/site-packages/__pycache__/build_utils.* || die

	# The flashinfer.data mapping also duplicates both backend modules inside
	# the package data directory; remove those copies and their bytecode.
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
