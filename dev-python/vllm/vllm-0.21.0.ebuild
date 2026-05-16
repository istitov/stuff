# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1
ROCM_VERSION=7.2

inherit distutils-r1 pypi rocm

DESCRIPTION="High-throughput, memory-efficient inference and serving engine for LLMs"
HOMEPAGE="
	https://github.com/vllm-project/vllm
	https://docs.vllm.ai/
	https://pypi.org/project/vllm/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cpu cuda rocm"
# VLLM_TARGET_DEVICE is single-valued; cpu, cuda, and rocm paths are
# mutually exclusive. Default (none) → empty target.
REQUIRED_USE="
	?? ( cpu cuda rocm )
	rocm? ( || ( ${ROCM_REQUIRED_USE} ) )
"

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
# USE=rocm: build with VLLM_TARGET_DEVICE=rocm. Pulls torchaudio +
# torchvision + numba + the runai-streamer/tensorizer/conch-triton
# trio from upstream's requirements/rocm.txt, plus the HIP libs that
# vllm's CMake `enable_language(HIP)` and the linked libtorch_hip
# resolve at link time (hipBLAS / hipBLASLt / hipFFT / hipRAND /
# hipSOLVER / hipSPARSE / hipCUB). Compiles the _C / _moe_C / _rocm_C
# extensions and csrc/rocm/*.cu via hipcc and the system ROCm
# toolchain at /opt/rocm. Inherits sci-ml/caffe2's MKL-MPI scrub
# (>=2.11.0-r90) — same link-pollution caveat as the cuda path.
# PYTORCH_ROCM_ARCH is derived from AMDGPU_TARGETS via rocm.eclass's
# get_amdgpu_flags. FetchContent of CK / spdlog / etc. happens during
# the vllm CMake build, hence RESTRICT="rocm? ( network-sandbox )".
#
# amd-quark (in requirements/rocm.txt as "for Quark quantization on
# ROCm") is deliberately omitted from RDEPEND: no direct `import` from
# vllm core code, only used by vllm.model_executor.layers.quantization.
# quark internals when Quark-quantized models are loaded.
# dev-python/amd-quark-bin in this overlay caps PYTHON_COMPAT at
# 3.{11,12}, which would block vllm on 3.13/3.14. Users wanting Quark
# quantization install amd-quark-bin separately.
# gfx1150 (Strix Point iGPU) rocm build verified on
# caffe2[rocm,amdgpu_targets_gfx1150,-nccl,-cusparselt] with
# AMDGPU_TARGETS=gfx1150.  Both runs produced four working HIP
# extensions (_C, _moe_C, _rocm_C, cumem_allocator) and a clean
# `import vllm` from the install tree.
# # verified 2026-05-08 for 0.20.1, 2026-05-16 for 0.21.0.
#
# USE=-cpu -cuda -rocm (default): build with VLLM_TARGET_DEVICE=empty
# — Python entrypoints import cleanly, backend kernels fail at first
# model-load. Useful if you only want the API surface for development.
RDEPEND="
	~sci-ml/pytorch-2.11.0[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/transformers-4.56.0[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/tokenizers-0.21.1[${PYTHON_SINGLE_USEDEP}]
	>=dev-python/xgrammar-0.2.0[${PYTHON_SINGLE_USEDEP}]
	<dev-python/xgrammar-1.0.0[${PYTHON_SINGLE_USEDEP}]
	~dev-python/compressed-tensors-0.15.0.1[${PYTHON_SINGLE_USEDEP}]
	app-alternatives/ninja
	$(python_gen_cond_dep '
		dev-python/regex[${PYTHON_USEDEP}]
		dev-python/cachetools[${PYTHON_USEDEP}]
		dev-python/psutil[${PYTHON_USEDEP}]
		sci-ml/sentencepiece[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		>=dev-python/requests-2.26.0[${PYTHON_USEDEP}]
		dev-python/tqdm[${PYTHON_USEDEP}]
		dev-python/blake3[${PYTHON_USEDEP}]
		dev-python/py-cpuinfo[${PYTHON_USEDEP}]
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
		>=dev-python/typing-extensions-4.10[${PYTHON_USEDEP}]
		>=dev-python/filelock-3.16.1[${PYTHON_USEDEP}]
		dev-python/partial-json-parser[${PYTHON_USEDEP}]
		>=dev-python/pyzmq-25.0.0[${PYTHON_USEDEP}]
		dev-python/msgspec[${PYTHON_USEDEP}]
		>=dev-python/gguf-0.17.0[${PYTHON_USEDEP}]
		>=dev-python/mistral-common-1.11.2[${PYTHON_USEDEP},image]
		>=media-libs/opencv-4.12.0[python,${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
		dev-python/six[${PYTHON_USEDEP}]
		dev-python/einops[${PYTHON_USEDEP}]
		~dev-python/depyf-0.20.0[${PYTHON_USEDEP}]
		dev-python/cloudpickle[${PYTHON_USEDEP}]
		dev-python/watchfiles[${PYTHON_USEDEP}]
		dev-python/python-json-logger[${PYTHON_USEDEP}]
		dev-python/pybase64[${PYTHON_USEDEP}]
		dev-python/cbor2[${PYTHON_USEDEP}]
		dev-python/ijson[${PYTHON_USEDEP}]
		dev-python/setproctitle[${PYTHON_USEDEP}]
		>=dev-python/openai-harmony-0.0.3[${PYTHON_USEDEP}]
		>=dev-python/anthropic-0.71.0[${PYTHON_USEDEP}]
		>=dev-python/model-hosting-container-standards-0.1.14[${PYTHON_USEDEP}]
		<dev-python/model-hosting-container-standards-1.0.0[${PYTHON_USEDEP}]
		dev-python/mcp[${PYTHON_USEDEP}]
		>=dev-python/opentelemetry-sdk-1.27.0[${PYTHON_USEDEP}]
		>=dev-python/opentelemetry-api-1.27.0[${PYTHON_USEDEP}]
		>=dev-python/opentelemetry-exporter-otlp-1.27.0[${PYTHON_USEDEP}]
		>=dev-python/opentelemetry-semantic-conventions-ai-0.4.1[${PYTHON_USEDEP}]
	')
	cpu? (
		>=sci-ml/caffe2-2.11.0-r90
		~sci-ml/torchaudio-2.11.0
		$(python_gen_cond_dep '
			>=dev-python/numba-0.65.0[${PYTHON_USEDEP}]
		')
	)
	cuda? (
		>=sci-ml/caffe2-2.11.0-r90
		~sci-ml/torchaudio-2.11.0
		~sci-ml/torchvision-0.26.0[${PYTHON_SINGLE_USEDEP}]
		~dev-python/flashinfer-python-0.6.8_p1[${PYTHON_SINGLE_USEDEP}]
		dev-python/tilelang[${PYTHON_SINGLE_USEDEP}]
		>=dev-python/quack-kernels-0.3.3[${PYTHON_SINGLE_USEDEP}]
		$(python_gen_cond_dep '
			>=dev-python/numba-0.65.0[${PYTHON_USEDEP}]
			>=dev-python/fastsafetensors-0.2.2[${PYTHON_USEDEP}]
		')
		dev-util/nvidia-cuda-toolkit:=
	)
	rocm? (
		>=sci-ml/caffe2-2.11.0-r90
		~sci-ml/torchaudio-2.11.0
		~sci-ml/torchvision-0.26.0[${PYTHON_SINGLE_USEDEP}]
		>=dev-python/runai-model-streamer-bin-0.15.7[${PYTHON_SINGLE_USEDEP}]
		~dev-python/tensorizer-2.10.1[${PYTHON_SINGLE_USEDEP}]
		dev-python/tilelang[${PYTHON_SINGLE_USEDEP}]
		$(python_gen_cond_dep '
			>=dev-python/numba-0.65.0[${PYTHON_USEDEP}]
			~dev-python/conch-triton-kernels-1.2.1[${PYTHON_USEDEP}]
			>=dev-util/amdsmi-7.0.2[${PYTHON_USEDEP}]
		')
		>=dev-util/hip-7.2:=
		>=sci-libs/hipBLAS-7.2:=
		>=sci-libs/hipBLASLt-7.2:=
		>=sci-libs/hipFFT-7.2:=
		>=sci-libs/hipRAND-7.2:=
		>=sci-libs/hipSOLVER-7.2:=
		>=sci-libs/hipSPARSE-7.2:=
		>=sci-libs/hipCUB-7.2:=
	)
"
BDEPEND="
	>=dev-build/cmake-3.26.1
	app-alternatives/ninja
	~sci-ml/pytorch-2.11.0[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		>=dev-python/setuptools-77.0.3[${PYTHON_USEDEP}]
		<dev-python/setuptools-81.0.0[${PYTHON_USEDEP}]
		>=dev-python/setuptools-scm-8.0[${PYTHON_USEDEP}]
		>=dev-python/packaging-24.2[${PYTHON_USEDEP}]
		dev-python/jinja2[${PYTHON_USEDEP}]
	')
	cuda? (
		dev-util/nvidia-cuda-toolkit:=
		$(python_gen_cond_dep '
			dev-python/apache-tvm-ffi[${PYTHON_USEDEP}]
		')
	)
	rocm? (
		>=dev-util/hip-7.2:=
		>=dev-util/hipcc-7.2:=
	)
"

# Tests need a model+inference setup; not wired up here.
# CPU build fetches oneDNN v3.10 from GitHub via CMake FetchContent.
# CUDA build similarly uses FetchContent for CUTLASS / spdlog / etc.
# during the _C / _moe_C / _vllm_fa* extension compile. Both paths
# need the network-sandbox bypass. # verified 2026-05-07 against
# 0.20.1; 0.21.0's FetchContent set wasn't re-audited at bump time.
RESTRICT="
	test
	cpu? ( network-sandbox )
	cuda? ( network-sandbox )
	rocm? ( network-sandbox )
"

# 0.20.x carried a patch to relax cmake/cpu_extension.cmake's libgomp
# probe so it would fall back to the system gcc-runtime libgomp when
# torch.libs/ contains no vendored copy.  Upstream 0.21.0's cmake now
# has an equivalent fallback (find_library(OPEN_MP NAMES gomp REQUIRED)
# without NO_DEFAULT_PATH) when VLLM_TORCH_GOMP_SHIM_DIR is empty, so
# the local patch is no longer needed.

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
		# 54 GiB → 8-10, 128 GiB → ~16. The OOM threshold was measured
		# against 0.20.1; 0.21.0's CUDA template set wasn't re-profiled
		# at bump time but the heavy instantiations (paged_attention,
		# layernorm_quant, w8a8/fp8) are unchanged, so MAX_JOBS=4 stays
		# a conservative default. # verified 2026-05-07 against 0.20.1.
		export MAX_JOBS=4
		export CMAKE_BUILD_PARALLEL_LEVEL=4
	elif use cpu; then
		export VLLM_TARGET_DEVICE=cpu
	elif use rocm; then
		export VLLM_TARGET_DEVICE=rocm
		# rocm.eclass turns AMDGPU_TARGETS into a semicolon-joined
		# list. vllm's CMakeLists reads PYTORCH_ROCM_ARCH and feeds
		# it to enable_language(HIP). Same MAX_JOBS throttle as the
		# cuda branch — HIP template instantiation in csrc/rocm/
		# (skinny_gemms, attention) hits comparable peak RSS.
		export PYTORCH_ROCM_ARCH=$(get_amdgpu_flags)
		export MAX_JOBS=4
		export CMAKE_BUILD_PARALLEL_LEVEL=4
	else
		export VLLM_TARGET_DEVICE=empty
	fi
	distutils-r1_src_configure
}
