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
IUSE="cpu"

# USE=cpu (default off): build with VLLM_TARGET_DEVICE=cpu so the
# Python entrypoints can actually drive inference on CPU hardware.
# Pulls torchaudio + numba (vllm's cpu.txt also lists intel-openmp on
# x86_64, but Intel ships it as a proprietary blob — we omit it; vllm
# falls back to the pthreads OpenMP shipped with sci-libs/openblas etc.)
#
# CAVEAT for USE=cpu: the link step inherits ::gentoo sci-ml/pytorch's
# public TorchConfig.cmake link interface, which exports MKL's MPI/
# cluster libs (libmkl_scalapack_ilp64, libmkl_cdft_core,
# libmkl_intel_thread, libmkl_blacs_intelmpi_ilp64). On hosts with a
# partial Intel oneAPI install these links fail. Workarounds: build
# pytorch with USE=-mkl, or install the full MKL/MPI stack. This is a
# sci-ml/pytorch packaging issue, not a vllm one.
#
# USE=-cpu (default): build with VLLM_TARGET_DEVICE=empty — Python
# entrypoints import cleanly, backend kernels fail at first model-load.
# Useful if you only want the API surface for development.
#
# Future cycles: USE flags for cuda / rocm. cuda needs the
# flashinfer/tilelang/apache-tvm-ffi stack we don't have; rocm needs
# amd-quark which currently excludes Python 3.13/3.14.
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
		~sci-ml/torchaudio-2.11.0
		>=dev-python/numba-0.65.0[${PYTHON_USEDEP}]
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
"

# Tests need a model+inference setup; not wired up here.
# CPU build fetches oneDNN v3.10 from GitHub via CMake FetchContent;
# allow network at build time (matches the kokoros/lemonade pattern).
RESTRICT="
	test
	cpu? ( network-sandbox )
"

PATCHES=(
	"${FILESDIR}/${P}-cpu-system-libgomp.patch"
)

# Pretend the version so setuptools-scm doesn't probe git.
export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}

src_configure() {
	if use cpu; then
		export VLLM_TARGET_DEVICE=cpu
	else
		export VLLM_TARGET_DEVICE=empty
	fi
	distutils-r1_src_configure
}
