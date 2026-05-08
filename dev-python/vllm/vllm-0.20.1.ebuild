# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="High-throughput, memory-efficient inference and serving engine for LLMs"
HOMEPAGE="
	https://github.com/vllm-project/vllm
	https://docs.vllm.ai/
	https://pypi.org/project/vllm/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cpu cuda"
# VLLM_TARGET_DEVICE is single-valued; cpu and cuda paths are
# mutually exclusive. Default (neither) → empty target.
REQUIRED_USE="?? ( cpu cuda )"

# USE=cpu (default off): build with VLLM_TARGET_DEVICE=cpu so the
# Python entrypoints can actually drive inference on CPU hardware.
# Pulls torchaudio + numba (vllm's cpu.txt also lists intel-openmp on
# x86_64, but Intel ships it as a proprietary blob — we omit it; vllm
# falls back to the pthreads OpenMP shipped with sci-libs/openblas etc.)
#
# CAVEAT (historical): ::gentoo sci-ml/pytorch's caffe2::mkl public
# link interface used to drag MKL's MPI / cluster libs (scalapack,
# cdft, blacs_intelmpi) and Intel-OpenMP threading (intel_thread)
# into every consumer link, breaking the build on hosts without
# Intel Cluster Edition + Compiler. We pin >=sci-ml/caffe2-2.11.0-r90
# below — this overlay's r90 fork ships a scrub patch on
# cmake/public/mkl.cmake that filters those libs and forces
# gnu_thread. Drop the pin once an equivalent upstream fix lands.
#
# USE=cuda: build with VLLM_TARGET_DEVICE=cuda. Pulls torchaudio +
# torchvision + numba and the full Tier-0..5 CUDA stack (flashinfer
# + tilelang + nvidia-cutlass-dsl + cuda-bindings + nvidia-cudnn-
# frontend + ...). Compiles the _C / _moe_C / _vllm_fa* CUDA C++
# extensions in setup.py via nvcc and the system CUDA toolkit at
# /opt/cuda. CMAKE_CUDA_HOST_COMPILER is pinned to the gcc-15 slot
# below — CUDA 13.2's nvcc rejects __GNUC__>15 via host_config.h
# (see feedback_cuda_13_host_compiler_gcc_15.md). FetchContent of
# CUTLASS / spdlog / etc. happens during the vllm CMake build, so
# RESTRICT="cuda? ( network-sandbox )" mirrors the cpu? pattern.
#
# CAVEAT (historical): same MKL-MPI link pollution as USE=cpu —
# ::gentoo sci-ml/pytorch with USE=mkl exported MKL MPI / cluster
# libs in its public link interface, breaking the cumem_allocator
# extension's link step on partial-MKL hosts. Fixed by the
# >=sci-ml/caffe2-2.11.0-r90 pin below: this overlay's r90 fork
# scrubs those libs from caffe2::mkl. Without that pin, all 339
# CUDA-compiled objects (_C / _moe_C / _vllm_fa2/3 extensions)
# would still build cleanly but the final cumem_allocator link
# would fail with "cannot find -lmkl_scalapack_ilp64".
#
# USE=-cpu -cuda (default): build with VLLM_TARGET_DEVICE=empty —
# Python entrypoints import cleanly, backend kernels fail at first
# model-load. Useful if you only want the API surface for development.
#
# rocm path remains future work (amd-quark currently excludes Python
# 3.13/3.14, and ROCm-specific kernels aren't packaged).
RDEPEND="
	dev-python/regex[${PYTHON_USEDEP}]
	dev-python/cachetools[${PYTHON_USEDEP}]
	dev-python/psutil[${PYTHON_USEDEP}]
	sci-ml/sentencepiece[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	>=dev-python/requests-2.26.0[${PYTHON_USEDEP}]
	dev-python/tqdm[${PYTHON_USEDEP}]
	dev-python/blake3[${PYTHON_USEDEP}]
	dev-python/py-cpuinfo[${PYTHON_USEDEP}]
	>=sci-ml/transformers-4.56.0[${PYTHON_USEDEP}]
	>=sci-ml/tokenizers-0.21.1[${PYTHON_USEDEP}]
	>=dev-python/protobuf-5.29.6[${PYTHON_USEDEP}]
	>=dev-python/fastapi-0.115.0[${PYTHON_USEDEP}]
	>=dev-python/aiohttp-3.13.3[${PYTHON_USEDEP}]
	>=dev-python/openai-2.0.0[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.12.0[${PYTHON_USEDEP}]
	>=dev-python/prometheus-client-0.18.0[${PYTHON_USEDEP}]
	dev-python/pillow[${PYTHON_USEDEP}]
	>=dev-python/prometheus-fastapi-instrumentator-7.0.0[${PYTHON_USEDEP}]
	>=dev-python/tiktoken-0.6.0[${PYTHON_USEDEP}]
	~dev-python/lm-format-enforcer-0.11.3[${PYTHON_USEDEP}]
	>=dev-python/llguidance-1.3.0[${PYTHON_USEDEP}]
	<dev-python/llguidance-1.4.0[${PYTHON_USEDEP}]
	~dev-python/outlines-core-0.2.14[${PYTHON_USEDEP}]
	>=dev-python/diskcache-5.6.3[${PYTHON_USEDEP}]
	>=dev-python/lark-1.2.2[${PYTHON_USEDEP}]
	>=dev-python/xgrammar-0.1.32[${PYTHON_USEDEP}]
	<dev-python/xgrammar-1.0.0[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.10[${PYTHON_USEDEP}]
	>=dev-python/filelock-3.16.1[${PYTHON_USEDEP}]
	dev-python/partial-json-parser[${PYTHON_USEDEP}]
	>=dev-python/pyzmq-25.0.0[${PYTHON_USEDEP}]
	dev-python/msgspec[${PYTHON_USEDEP}]
	>=dev-python/gguf-0.17.0[${PYTHON_USEDEP}]
	>=dev-python/mistral-common-1.11.0[${PYTHON_USEDEP},image]
	>=media-libs/opencv-4.12.0[python,${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]
	dev-python/einops[${PYTHON_USEDEP}]
	~dev-python/compressed-tensors-0.15.0.1[${PYTHON_USEDEP}]
	~dev-python/depyf-0.20.0[${PYTHON_USEDEP}]
	dev-python/cloudpickle[${PYTHON_USEDEP}]
	dev-python/watchfiles[${PYTHON_USEDEP}]
	dev-python/python-json-logger[${PYTHON_USEDEP}]
	app-alternatives/ninja
	dev-python/pybase64[${PYTHON_USEDEP}]
	dev-python/cbor2[${PYTHON_USEDEP}]
	dev-python/ijson[${PYTHON_USEDEP}]
	dev-python/setproctitle[${PYTHON_USEDEP}]
	>=dev-python/openai-harmony-0.0.3[${PYTHON_USEDEP}]
	>=dev-python/anthropic-0.71.0[${PYTHON_USEDEP}]
	>=dev-python/model-hosting-container-standards-0.1.13[${PYTHON_USEDEP}]
	<dev-python/model-hosting-container-standards-1.0.0[${PYTHON_USEDEP}]
	dev-python/mcp[${PYTHON_USEDEP}]
	>=dev-python/opentelemetry-sdk-1.27.0[${PYTHON_USEDEP}]
	>=dev-python/opentelemetry-api-1.27.0[${PYTHON_USEDEP}]
	>=dev-python/opentelemetry-exporter-otlp-1.27.0[${PYTHON_USEDEP}]
	>=dev-python/opentelemetry-semantic-conventions-ai-0.4.1[${PYTHON_USEDEP}]
	~sci-ml/pytorch-2.11.0[${PYTHON_USEDEP}]
	cpu? (
		>=sci-ml/caffe2-2.11.0-r90
		~sci-ml/torchaudio-2.11.0
		>=dev-python/numba-0.65.0[${PYTHON_USEDEP}]
	)
	cuda? (
		>=sci-ml/caffe2-2.11.0-r90
		~sci-ml/torchaudio-2.11.0
		~sci-ml/torchvision-0.26.0[${PYTHON_USEDEP}]
		>=dev-python/numba-0.65.0[${PYTHON_USEDEP}]
		~dev-python/flashinfer-python-0.6.8_p1[${PYTHON_USEDEP}]
		dev-python/tilelang[${PYTHON_USEDEP}]
		>=dev-python/fastsafetensors-0.2.2[${PYTHON_USEDEP}]
		>=dev-python/quack-kernels-0.3.3[${PYTHON_USEDEP}]
		dev-util/nvidia-cuda-toolkit:=
	)
"
BDEPEND="
	>=dev-build/cmake-3.26.1
	app-alternatives/ninja
	>=dev-python/setuptools-77.0.3[${PYTHON_USEDEP}]
	<dev-python/setuptools-81.0.0[${PYTHON_USEDEP}]
	>=dev-python/setuptools-scm-8.0[${PYTHON_USEDEP}]
	>=dev-python/packaging-24.2[${PYTHON_USEDEP}]
	dev-python/jinja2[${PYTHON_USEDEP}]
	~sci-ml/pytorch-2.11.0[${PYTHON_USEDEP}]
	cuda? (
		dev-util/nvidia-cuda-toolkit:=
		dev-python/apache-tvm-ffi[${PYTHON_USEDEP}]
	)
"

# Tests need a model+inference setup; not wired up here.
# CPU build fetches oneDNN v3.10 from GitHub via CMake FetchContent.
# CUDA build similarly uses FetchContent for CUTLASS / spdlog / etc.
# during the _C / _moe_C / _vllm_fa* extension compile. Both paths
# need the network-sandbox bypass. # verified 2026-05-07.
RESTRICT="
	test
	cpu? ( network-sandbox )
	cuda? ( network-sandbox )
"

PATCHES=(
	"${FILESDIR}/${P}-cpu-system-libgomp.patch"
)

# Pretend the version so setuptools-scm doesn't probe git.
export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}

src_configure() {
	if use cuda; then
		export VLLM_TARGET_DEVICE=cuda
		# CUDA 13.2's nvcc rejects gcc>15 via crt/host_config.h; this
		# host's active gcc is 16. Pin nvcc's host compiler to the
		# gcc-15 slot. See feedback_cuda_13_host_compiler_gcc_15.md
		# for the rationale and broader applicability.
		export CUDAHOSTCXX=/usr/bin/x86_64-pc-linux-gnu-g++-15
		export CMAKE_ARGS+=" -DCMAKE_CUDA_HOST_COMPILER=${CUDAHOSTCXX}"

		# vllm's heavy CUDA template instantiations
		# (paged_attention_v*, layernorm_quant_kernels, w8a8/fp8/...)
		# can each peak at 3-4 GiB during cudafe++. With ninja's
		# default 24-way parallelism this OOM-kills on a 31 GiB host
		# (cudafe++ dies with SIGKILL, "[code=9]"). MAX_JOBS is the
		# env var vllm's setup.py reads to throttle the CMake build;
		# CMAKE_BUILD_PARALLEL_LEVEL backs it up for direct cmake
		# --build invocations. Tune this per-host: 31 GiB → 4-6,
		# 54 GiB → 8-10, 128 GiB → ~16. # verified 2026-05-07 against
		# 0.20.1 with MAX_JOBS=4 on this 31 GiB host.
		export MAX_JOBS=4
		export CMAKE_BUILD_PARALLEL_LEVEL=4
	elif use cpu; then
		export VLLM_TARGET_DEVICE=cpu
	else
		export VLLM_TARGET_DEVICE=empty
	fi
	distutils-r1_src_configure
}
