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

# First-cycle landing strategy: build with VLLM_TARGET_DEVICE=empty so
# only common.txt deps are required and no per-device CMake C++
# extensions are compiled. The Python entrypoints (`vllm.LLM`,
# `vllm serve …`, the OpenAI-compatible HTTP API surface) all import
# cleanly; backend kernels fail at first model-load.
#
# Future cycles: USE flags for cpu / cuda / rocm that flip the env var
# and pull in the per-device requirements. cpu needs torchaudio, numba
# and intel-openmp (Intel-proprietary, x86_64-only); rocm needs
# amd-quark which excludes Python 3.13/3.14; cuda needs the
# flashinfer/tilelang/apache-tvm-ffi stack we don't have.
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

# Pretend the version so setuptools-scm doesn't probe git.
export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}
export VLLM_TARGET_DEVICE=empty

# Tests need a model+inference setup; not wired up here.
RESTRICT="test"
